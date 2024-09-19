# Install Cert-Manager and Issuers

## Using kubectl

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.yaml

**Modify Ingress Resource**: Modify ingress resource to have annotations as this

<!-- For testing -->

#annotations:
#cert-manager.io/cluster-issuer: "letsencrypt-staging"

<!-- For production -->

#cert-manager.io/cluster-issuer: "letsencrypt-production"

## Using helm

helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
 cert-manager jetstack/cert-manager \
 --namespace cert-manager \
 --create-namespace \
 --version v1.15.3 \
 --set crds.enabled=true

---

# Cert-manager Setup on AWS

## Setting Cert-Manager to use Letsencrypt on AWS using dns01 solver challenge

1. Create an IAM OIDC provider for your cluster

```
eksctl utils associate-iam-oidc-provider --cluster nextgenhub_cluster --approve
```

2. Create an IAM policy

```
aws iam create-policy \
     --policy-name cert-manager-acme-dns01-route53 \
     --description "This policy allows cert-manager to manage ACME DNS01 records in Route53 hosted zones. See https://cert-manager.io/docs/configuration/acme/dns01/route53" \
     --policy-document file://route53.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOF
```

3. Create an IAM role and associate it with a Kubernetes service account
   Steps carried out:

- creates a new dedicated Kubernetes ServiceAccount in the cert-manager namespace, and
- configures a new AWS Role with the permissions defined in the policy from the previous step.
- configures the Role so that it can be only be assumed by clients with tokens for new dedicated Kubernetes ServiceAccount in this EKS cluster.

```
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
eksctl create iamserviceaccount \
  --name cert-manager-acme-dns01-route53 \
  --namespace cert-manager \
  --cluster nextgenhub_cluster \
  --role-name cert-manager-acme-dns01-route53 \
  --attach-policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/cert-manager-acme-dns01-route53 \
  --approve
```

OR

```
cat >my_service_account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cert-manager-acme-dns01-route53
  namespace: nxtgenhub-helm
EOF

kubectl apply -f my_service_account.yaml

account_id=$(aws sts get-caller-identity --query "Account" --output text)

oidc_provider=$(aws eks describe-cluster --name nextgenhub_cluster --region eu-north-1 --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

export namespace=nxtgenhub-helm
export service_account=cert-manager-acme-dns01-route53

cat >trust-relationship.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$account_id:oidc-provider/$oidc_provider"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$oidc_provider:aud": "sts.amazonaws.com",
          "$oidc_provider:sub": "system:serviceaccount:$namespace:$service_account"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name service_account_role --assume-role-policy-document file://trust-relationship.json --description "my-role-description"

aws iam attach-role-policy --role-name service_account_role --policy-arn=arn:aws:iam::837538001765:policy/cert-manager-acme-dns01-route53

kubectl annotate serviceaccount -n $namespace $service_account eks.amazonaws.com/role-arn=arn:aws:iam::837538001765:role/service_account_role


```

### Confirm policy attached to role

```
aws iam get-role --role-name service_account_role --query Role.AssumeRolePolicyDocument

aws iam list-attached-role-policies --role-name service_account_role --query AttachedPolicies[].PolicyArn --output text

kubectl describe serviceaccount $service_account -n $namespace

```

NOTE: Cleanup if error:

```
eksctl delete iamserviceaccount --region=eu-north-1 \
--cluster nextgenhub_cluster \
--name=cert-manager-acme-dns01-route53 \
--namespace=cert-manager
```

4. Grant permission for cert-manager to create ServiceAccount tokens

```
kubectl apply -f rbac.yaml
```

5. Create a ClusterIssuer for Let's Encrypt Staging

```
kubectl apply -f staging-issuer.yaml
```

6. check the status of the ClusterIssuer:

```
kubectl describe clusterissuer letsencrypt-staging
```

7. Re-issue the Certificate using Let's Encrypt

```
kubectl patch certificate www-nxtgen --type merge  -p '{"spec":{"issuerRef":{"name":"letsencrypt-staging"}}}'
```

8. Restart the webserver to use the new certificate

```
kubectl rollout restart deployment <webserver>
```

### For Production certificate

NOTE: To use env variables in your yaml files and apply:
Install envsubst from https://github.com/a8m/envsubst

```
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
envsubst < clusterissuer-lets-encrypt-production.yaml | kubectl apply -f  -
```

1. Apply the prod-issuer.yaml and patch the certificate to use the production ClusterIssuer

```
kubectl patch certificate www --type merge  -p '{"spec":{"issuerRef":{"name":"letsencrypt-production"}}}'
```
