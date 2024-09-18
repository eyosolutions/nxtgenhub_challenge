## Ingress Controllers

### Using Nginx Ingress Controller

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.6.4/deploy/static/provider/cloud/deploy.yaml
<!-- OR -->
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml
kubectl -n ingress-nginx get pod

<!-- OR Using Helm -->
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update


helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace --dry-run=client

helm dependency build CHART [flags]
```

### Using Traefik Ingress Controller

```
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik
```

### Prometheus/Grafana

helm repo update

helm install prometheus \
 prometheus-community/kube-prometheus-stack \
 --namespace monitoring \
 --create-namespace \
 --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

helm install my-kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 62.7.0

## Autoscaling

### Increase the load

```
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- sh -c "while sleep 0.01; do wget -q -O- http://nxtgenhub.eyoghanatest.site; done"

kubectl get hpa webserver-deploy --watch
```
