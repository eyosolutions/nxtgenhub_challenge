# Nxtgenhub DevOps Challenge

## Overview

The **Nxtgenhub DevOps Challenge** is a project designed to demonstrate end-to-end DevOps skills. It involves creating a secure, containerized web server deployed onto a Kubernetes cluster. The solution includes Kubernetes manifests, Helm charts, application monitoring, logging, and alerting, as well as an automated CI/CD pipeline.

### Key Features:

1. **Nginx Web Server**: A simple Nginx web server hosting a static webpage (`index.html`).
2. **Containerization**: The web server is containerized using Docker, and the image is hosted on Docker Hub.
3. **Kubernetes Deployment**: The application is deployed onto Kubernetes clusters using Docker Desktop and AWS EKS.
4. **Helm Charts**: Kubernetes manifests and Helm charts are created for simplified deployment and management.
5. **Ingress and HTTPS**: An ingress controller is set up with TLS certificates to enable secure communication over HTTPS.
6. **Monitoring & Logging**: Prometheus, Grafana, and Alertmanager are used for application monitoring, logging, and alerting.
7. **CI/CD**: Jenkins or GitHub Actions and ArgoCD are used to automate the CI/CD pipeline for deployments.

---

## Table of Contents

- [Setup Instructions](#setup-instructions)
- [Docker](#docker)
- [Kubernetes Setup](#kubernetes-setup)
- [Helm Chart](#helm-chart)
- [Monitoring, Logging, and Alerting](#monitoring-logging-and-alerting)
- [CI/CD Pipeline](#ci-cd-pipeline)
- [Contributing](#contributing)

---

## Setup Instructions

### Prerequisites:

- **Docker** (for containerization)
- **Kubernetes** (e.g., Docker Desktop, AWS EKS, or AKS)
- **Helm** (for managing Kubernetes resources)
- **Jenkins or GitHub Actions** (for CI/CD)
- **ArgoCD** (for GitOps-style deployments)
- **Cert-manager** (for automating HTTPS certificates)
- **Prometheus, Grafana, Alertmanager** (for monitoring and alerting)

### Quickstart:

1. Clone the repository:

   ```bash
   git clone https://github.com/eyosolutions/nxtgenhub_challenge.git
   cd nxtgenhub_challenge/webserver/
   ```

2. Build the Docker image:

   ```bash
   docker build -t your-dockerhub-username/nxtgenhub-webserver:v1 .
   ```

3. Push the image to Docker Hub:
   ```bash
   docker push your-dockerhub-username/nxtgenhub-webserver:v1
   ```

---

## Docker

### Dockerfile Overview:

The `Dockerfile` defines the web server using an Nginx image and copies the static `index.html` page to the Nginx web root. Note that the `Dockerfile` itself uses the nginx digest instead of the image and tag to ensure the same image is pulled each time.

```Dockerfile
FROM nginx:1.27.1-alpine-slim
COPY index.html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Local Testing:

To test locally, run:

```bash
docker run -d -p 80:80 your-dockerhub-username/nxtgen-webserver:v1
```

Navigate to `http://localhost` to view the web page.

---

## Kubernetes Setup

### Deployment on Docker Desktop:

1. Create Kubernetes manifests (`namespace.yaml`, `deployment.yaml`, `service.yaml`, `ingress.yaml`, `ingress-controller.yaml`).
2. Apply the manifests:
   ```bash
   kubectl apply -f k8s-manifests/
   ```

### Deployment on EKS:

1. Create an EKS cluster using `eksctl` or the AWS console.
2. Deploy using Helm:
   ```bash
   helm install nxtgenhub ./helm-chart
   ```

### Ingress with HTTPS:

- Use **cert-manager** to automatically manage HTTPS certificates:
  ```bash
  kubectl apply -f cert-manager.yaml
  ```
- Ensure your Ingress resource is configured for HTTPS using the certificate provided by cert-manager.

---

## Helm Chart

The Helm chart for the application automates the deployment of the web server, services, and ingress. The Ingress controller is added as a Helm dependency.

- Install the Helm chart:
  ```bash
  helm install nxtgenhub ./helm-chart
  ```
- To upgrade the application:
  ```bash
  helm upgrade nxtgenhub ./helm-chart
  ```

---

## Monitoring, Logging, and Alerting

### Monitoring Setup:

1. **Prometheus** collects metrics from the application.
2. **Grafana** provides visualization dashboards for these metrics.
3. **Alertmanager** sends alerts based on defined Prometheus rules.

To deploy monitoring:

```bash
kubectl apply -f monitoring/
```

### Alerts:

- Prometheus alerting rules are configured to detect common issues (e.g., high memory or CPU usage).
- Alerts are sent via email or Slack, depending on the configured alerting system.

---

## CI/CD Pipeline

### Jenkins or GitHub Actions:

- The CI pipeline builds the Docker image and pushes it to Docker Hub.
- The CD pipeline is triggered using **ArgoCD** to deploy the latest version to the Kubernetes cluster.

1. **Jenkins**: A Jenkins pipeline (`Jenkinsfile`) automates the build and push process.
2. **GitHub Actions**: Alternatively, use GitHub Actions (`.github/workflows/ci.yml`) to perform the same tasks.

---

## Contributing

Feel free to contribute by:

1. Submitting pull requests.
2. Opening issues on GitHub.
