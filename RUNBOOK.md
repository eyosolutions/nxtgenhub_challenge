
# Nxtgenhub DevOps Challenge - Runbook

## Overview
This runbook provides operational procedures for managing, troubleshooting, and maintaining the Nxtgenhub DevOps Challenge application in production.

---

## Table of Contents
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Monitoring and Alerts](#monitoring-and-alerts)
- [On-Call Procedures](#on-call-procedures)
- [Contact Information](#contact-information)

---

## 1. Deployment

### Jenkins Pipeline:
1. **Build**: The Docker image is built by Jenkins or GitHub Actions.
2. **Push**: The image is pushed to Docker Hub.
3. **Deploy**: ArgoCD detects changes in the repository and automatically syncs them to the Kubernetes cluster.

### Manual Deployment (Helm):
```bash
helm upgrade nxtgenhub ./helm-chart
```

---

## 2. Troubleshooting

### Common Issues:

#### 2.1 Nginx Service Unavailable:
- **Cause**: Ingress misconfiguration or Nginx pod failure.
- **Solution**: 
   1. Check Ingress status:
      ```bash
      kubectl get ingress
      ```
   2. Restart the Nginx pod:
      ```bash
      kubectl rollout restart deployment nginx
      ```

#### 2.2 SSL Certificate Expiration:
- **Cause**: Cert-manager failed to renew the certificate.
- **Solution**: 
   1. Check cert-manager logs:
      ```bash
      kubectl logs -n cert-manager <cert-manager-pod>
      ```
   2. Reapply certificate manifest:
      ```bash
      kubectl apply -f cert-manager.yaml
      ```

---

## 3. Monitoring and Alerts

### Monitoring Dashboard:
- **Grafana** URL: `http://<grafana-endpoint>:3000`
- Default credentials: `admin/admin`

### Alerts:
- **Critical Alerts**:
  - High CPU or memory usage on Nginx
  - Pod restarts exceeding threshold
  - Unresponsive web server
- Check **Prometheus** for alert triggers:
  ```bash
  kubectl get pods -n monitoring
  ```

### Alert Escalation:
- Alerts are sent to the on-call team via Slack. If the issue persists, escalate to Level 2 support.

---

## 4. On-Call Procedures

### Incident Response:
1. Acknowledge the alert.
2. Follow troubleshooting steps in section 2 based on the type of alert.
3. Escalate if the issue cannot be resolved within 30 minutes.

---

## 5. Contact Information
- **DevOps Team**: devops@nxtgenhub.com
- **On-Call Engineer**: +123-456-7890

---

This runbook is intended to guide on-call engineers through common scenarios and incidents in the Nxtgenhub DevOps Challenge application. It should be regularly updated to reflect any changes in architecture or processes.
