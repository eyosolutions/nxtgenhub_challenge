# RUNBOOK

## Application Overview

**Name**: Nxtgenhub DevOps Challenge

This application consists of an Nginx-based web server deployed on Kubernetes clusters. The project involves creating Kubernetes manifests, Helm charts, automating the deployment using CI/CD pipelines, and implementing application monitoring, logging, and alerting.

---

## Table of Contents

1. [Web Server Overview](#web-server-overview)
2. [Setup Instructions](#setup-instructions)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [Helm Chart](#helm-chart)
5. [Ingress Controller and TLS Management](#ingress-controller-and-tls-management)
6. [Monitoring, Logging, and Alerting](#monitoring-logging-and-alerting)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Troubleshooting](#troubleshooting)

---

## Web Server Overview

The web server is an Nginx server that hosts a static webpage (`index.html`). This page displays a simple message: "Hello, World!"

- **Image**: Nginx (containerized using Docker)
- **Source Code**: A static HTML page copied into the container

The Nginx image is built into a Docker image and hosted on Docker Hub.

---

## Setup Instructions

### Prerequisites

- Docker installed
- Kubernetes cluster (Docker Desktop, AWS EKS, or Azure AKS)
- Helm installed
- Cert-manager for TLS certificate management
- Prometheus, Grafana, and Alertmanager for monitoring and alerting
- Jenkins or GitHub Actions for CI/CD
- ArgoCD for automated deployments

---

## Kubernetes Deployment

The application can be deployed in different Kubernetes environments (e.g., Docker Desktop or AWS EKS).

### Deployment on Docker Desktop

1. Install and enable Kubernetes in Docker Desktop.
2. Apply the Kubernetes manifests or Helm charts to the cluster:
   ```bash
   kubectl apply -f k8s/manifests/
   ```

### Deployment on AWS EKS

1. Create an AWS account and set up IAM access.
2. Use the provided `createk8sCluster.sh` script in the `k8s/aws_eks_option/` directory to create the EKS cluster.
   ```bash
   ./createk8sCluster.sh
   ```

Once the cluster is created, apply the Kubernetes manifests or Helm charts as above.

---

## Helm Chart

The Helm chart automates the deployment of the Nginx web server, including Kubernetes resources such as services, ingress, and ingress-controller.

### Usage

1. Update dependencies and install the Helm chart:
   ```bash
   helm dependency update k8s/helm-webserver/
   helm upgrade --install webserver k8s/helm-webserver/ -n <namespace>
   ```

### Ingress Controller Installation

You can install an ingress controller using kubectl or Helm. For example, using the NGINX ingress controller:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
```

---

## Ingress Controller and TLS Management

An ingress controller is used to expose the application externally. Certificates are managed using cert-manager and Let's Encrypt.

### Certificate Management

1. Install cert-manager:

   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.yaml
   ```

2. Apply the staging or production Let's Encrypt cluster issuer:

   ```bash
   kubectl apply -f k8s/certificate_management/using_http01/staging-issuer.yaml -n <namespace>
   ```

3. Ensure that the ingress resource is annotated to use the appropriate issuer for certificate management.

---

## Monitoring, Logging, and Alerting

Monitoring, logging, and alerting are essential for tracking the health of your Kubernetes cluster and the Nginx application.

### Prometheus and Grafana Installation

1. Install the metrics server:

   ```bash
   helm upgrade --install metrics-server metrics-server/metrics-server --namespace monitoring --create-namespace
   ```

2. Install Prometheus, Grafana, and Alertmanager:

   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f custom_values.yaml --namespace monitoring --create-namespace
   ```

3. Configure Prometheus to collect metrics from the Nginx application using the `nginx-exporter`:
   ```bash
   helm install my-prometheus-nginx-exporter prometheus-community/prometheus-nginx-exporter --version 0.2.2
   ```

---

## CI/CD Pipeline

### CI Pipeline

The CI pipeline builds the Docker image for the Nginx web server and pushes it to Docker Hub.

- **Tools**: Jenkins or GitHub Actions
- **Process**:
  1. Build the Docker image.
  2. Push the image to Docker Hub.

### CD Pipeline

The CD pipeline deploys the application to Kubernetes clusters.

- **Tool**: ArgoCD
- **Process**:
  1. Monitor the repository for updates to the Helm chart or Kubernetes manifests.
  2. Automatically deploy the application upon changes.

---

## Troubleshooting

### Common Issues

- **Ingress Controller Not Working**:

  - Check if the ingress controller is installed and running.
  - Ensure that the ingress resource has the correct annotations for TLS management.

- **Certificate Not Issued**:

  - Use `kubectl describe certificate` to diagnose certificate issues.
  - Ensure that cert-manager is installed and the ingress resource is properly annotated.

- **Metrics Not Collected**:
  - Verify Prometheus and NGINX exporter configurations.
  - Ensure that the correct service monitor is in place to collect application metrics.

## On-Call Procedures

### Incident Response:

1. Acknowledge the alert.
2. Follow troubleshooting steps in section 2 based on the type of alert.
3. Escalate if the issue cannot be resolved within 30 minutes.

---

## 5. Contact Information

- **DevOps Team**: devops@nxtgenhub.com
- **On-Call Engineer**: +123-456-7890

---

This runbook is intended to guide engineers in deploying, managing, and troubleshooting the Nxtgenhub DevOps Challenge project.
