#!/bin/bash

# Deleting the nodegroup and cluster
# delete nodegroup first

# Cluster Parameters
CLUSTER_NAME="nextgenhub_cluster"
NODE_GROUP_NAME="eks_nodegroup"

aws eks delete-nodegroup --cluster-name ${CLUSTER_NAME} --nodegroup-name ${NODE_GROUP_NAME}

# Wait for node-group deletion
aws eks wait nodegroup-deleted --cluster-name ${CLUSTER_NAME} --nodegroup-name ${NODE_GROUP_NAME}

# delete the cluster after deleting the nodegroup
aws eks delete-cluster --name ${CLUSTER_NAME}