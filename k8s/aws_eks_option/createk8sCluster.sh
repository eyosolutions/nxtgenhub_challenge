#!/bin/bash

# Variables declaration
# -------------------------------------

# Cluster Parameters
CLUSTER_NAME="nextgenhub_cluster"
SUBNET1_ID="subnet-066a757b64c15f8d6"
SUBNET2_ID="subnet-04bb1300c137953c8"
SUBNET3_ID="subnet-0c4e5c9de6f5b4607"
SECURITY_GROUP_ID="sg-0bc8e3f20e6dac099"
INSTANCE_TYPE="t3.medium"

# Node Autoscaling parameters
NODE_GROUP_NAME="eks_nodegroup"
NODE_MIN_SIZE=1
NODE_MAX_SIZE=3
DESIRED_SIZE=2

EKS_TRUST_FILE="file://trust.json"
NODE_GROUP_TRUST_FILE="file://eks-nodegroup-trust-policy.json"
ACCOUNT_ID=837538001765

# End of Variable Declarations

current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

logfile="/c/logs/eks_${current_datetime}.log"

# Function to log to both file and terminal
log() {
    echo "$current_datetime: $1" >> "$logfile"
}

# Function to log and exit on error
log_and_exit() {
    echo "$current_datetime: $1" >> "$logfile"
    exit 1
}

# PART 1
# Create an IAM Role for EKS cluster to be created
## Write code to verify if a trust.json policy exist else create one
log "Verify role via trust.json policy"
aws iam get-role --role-name eksServiceRole

# If no trsut policy exist, create one as ff:
if [ $? -ne 0 ]; then
  aws iam create-role --role-name eksServiceRole --assume-role-policy-document ${EKS_TRUST_FILE}
  log "IAM Policy/Role for EKS created"
else
  log "Policy/Role via trust.json policy already exist"
fi

# Attach the EKS service and cluster policy to the role:
aws iam attach-role-policy --role-name eksServiceRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSServicePolicy
log "AmazonEKSServicePolicy attached to eksServiceRole"

aws iam attach-role-policy --role-name eksServiceRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
log "AmazonEKSClusterPolicy attached to eksServiceRole"

# Create the EKS Cluster
log "Creating EKS Cluster ..."
aws eks create-cluster --name ${CLUSTER_NAME} --role-arn arn:aws:iam::${ACCOUNT_ID}:role/eksServiceRole --resources-vpc-config subnetIds=${SUBNET1_ID},${SUBNET2_ID},securityGroupIds=${SECURITY_GROUP_ID}

if [ $? -ne 0 ]; then
  log_and_exit "EKS Cluster could not be created."
else
  log "EKS Cluster successfully created"
fi

# Wait for Cluster creation to be completed before creating nodegroup
# sleep 1m

# PART 2
# Create the Role for the nodes within the cluster attach necessary policies
## Write code to verify if eks-nodegroup-trust-policy.json policy/role exist else creste one
log "Verify role via eks-nodegroup-trust-policy.json"
aws iam get-role --role-name MyCustomEKSNodeGroupRole

# If no eks-nodegroup-trust-policy.json policy exist, create one as ff:
if [ $? -ne 0 ]; then
  aws iam create-role --role-name MyCustomEKSNodeGroupRole --assume-role-policy-document ${NODE_GROUP_TRUST_FILE}
  log "Nodegroup role via eks-nodegroup-trust-policy.json created."
else
  log "Policy/Role via eks-nodegroup-trust-policy.json already exist"
fi

# Attach the necessary policies to the role created
aws iam attach-role-policy --role-name MyCustomEKSNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
log "AmazonEKSWorkerNodePolicy attached to eksServiceRole"

aws iam attach-role-policy --role-name MyCustomEKSNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
log "AmazonEKS_CNI_Policy attached to eksServiceRole"

aws iam attach-role-policy --role-name MyCustomEKSNodeGroupRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
log "AmazonEC2ContainerRegistryReadOnly attached to eksServiceRole"

# sleep 8m
aws eks wait cluster-active --name ${CLUSTER_NAME}

# Create a Node Group using the above role
log "Creating Nodegroup for the cluster ..."
aws eks create-nodegroup --cluster-name ${CLUSTER_NAME} --nodegroup-name ${NODE_GROUP_NAME} --node-role arn:aws:iam::${ACCOUNT_ID}:role/MyCustomEKSNodeGroupRole --subnets ${SUBNET1_ID} ${SUBNET2_ID} ${SUBNET3_ID} --instance-types ${INSTANCE_TYPE} --scaling-config minSize=${NODE_MIN_SIZE},maxSize=${NODE_MAX_SIZE},desiredSize=${DESIRED_SIZE}

if [ $? -ne 0 ]; then
  log_and_exit "EKS Cluster Nodegroup and Nodes could not be created."
else
  log "EKS Cluster Nodegroup and Nodes successfully created"
fi

# Update 'kubeconfig' - To manage your cluster with kubectl, update your kubeconfig file:
aws eks update-kubeconfig --name ${CLUSTER_NAME} || log "EKS Cluster updated successfully in local kubeconfig."

log "EKS Cluster creation completed and successful."

# Rename eks cluster context to a shorter name
# kubectx <cluster-name>=long-name-of-aws-cluster
