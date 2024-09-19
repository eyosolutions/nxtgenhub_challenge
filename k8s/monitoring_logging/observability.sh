#!/bin/bash

# Metric-Server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
 --namespace monitoring \
 --create-namespace

# Prometheus Stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack --version 62.7.0 \
 --namespace monitoring \
 --create-namespace

# Graafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install my-grafana grafana/grafana --version 8.5.1 \
 --namespace grafana \
 --create-namespace
