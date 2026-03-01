#!/bin/bash
# ENSEMBLE - Grafana Cloud Kubernetes Monitoring Stack
# Deploys Grafana Alloy-based k8s-monitoring via Helm into the otel-demo namespace
#
# Prerequisites:
#   - Kubernetes cluster with kubectl access
#   - Helm 3 installed
#   - Replace credential placeholders with real values from your Grafana Cloud portal
#
# Usage:
#   chmod +x deploy-k8s-monitoring.sh
#   ./deploy-k8s-monitoring.sh

set -euo pipefail

# ─── Add Grafana Helm repo ────────────────────────────────────────────────────
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# ─── Deploy k8s-monitoring stack ──────────────────────────────────────────────
helm upgrade --install --version ^2 --atomic --timeout 300s \
  grafana-k8s-monitoring grafana/k8s-monitoring \
  --namespace "otel-demo" --create-namespace --values - <<'EOF'
cluster:
  name: ensemble

destinations:
  - name: grafana-cloud-metrics
    type: prometheus
    url: https://prometheus-prod-58-prod-eu-central-0.grafana.net/api/prom/push
    auth:
      type: basic
      username: "<your-metrics-username>"
      password: "<your-grafana-cloud-api-token>"

  - name: grafana-cloud-logs
    type: loki
    url: https://logs-prod-039.grafana.net/loki/api/v1/push
    auth:
      type: basic
      username: "<your-logs-username>"
      password: "<your-grafana-cloud-api-token>"

  - name: grafana-cloud-traces
    type: otlp
    url: https://tempo-prod-27-prod-eu-central-0.grafana.net:443
    protocol: grpc
    auth:
      type: basic
      username: "<your-traces-username>"
      password: "<your-grafana-cloud-api-token>"
    metrics:
      enabled: false
    logs:
      enabled: false
    traces:
      enabled: true

clusterMetrics:
  enabled: true
  opencost:
    enabled: true
    metricsSource: grafana-cloud-metrics
    opencost:
      exporter:
        defaultClusterId: ensemble
      prometheus:
        existingSecretName: grafana-cloud-metrics-grafana-k8s-monitoring
        external:
          url: https://prometheus-prod-58-prod-eu-central-0.grafana.net/api/prom
  kepler:
    enabled: true

clusterEvents:
  enabled: true

podLogs:
  enabled: true

applicationObservability:
  enabled: true
  receivers:
    otlp:
      grpc:
        enabled: true
        port: 4317
      http:
        enabled: true
        port: 4318
    zipkin:
      enabled: true
      port: 9411
  connectors:
    grafanaCloudMetrics:
      enabled: true

alloy-metrics:
  enabled: true
  alloy:
    extraEnv:
      - name: GCLOUD_RW_API_KEY
        value: "<your-grafana-cloud-api-token>"
      - name: CLUSTER_NAME
        value: ensemble
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: GCLOUD_FM_COLLECTOR_ID
        value: grafana-k8s-monitoring-$(CLUSTER_NAME)-$(NAMESPACE)-$(POD_NAME)
  remoteConfig:
    enabled: true
    url: https://fleet-management-prod-024.grafana.net
    auth:
      type: basic
      username: "<your-fleet-management-instance-id>"
      passwordFrom: sys.env("GCLOUD_RW_API_KEY")

alloy-singleton:
  enabled: true
  alloy:
    extraEnv:
      - name: GCLOUD_RW_API_KEY
        value: "<your-grafana-cloud-api-token>"
      - name: CLUSTER_NAME
        value: ensemble
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: GCLOUD_FM_COLLECTOR_ID
        value: grafana-k8s-monitoring-$(CLUSTER_NAME)-$(NAMESPACE)-$(POD_NAME)
  remoteConfig:
    enabled: true
    url: https://fleet-management-prod-024.grafana.net
    auth:
      type: basic
      username: "<your-fleet-management-instance-id>"
      passwordFrom: sys.env("GCLOUD_RW_API_KEY")

alloy-logs:
  enabled: true
  alloy:
    extraEnv:
      - name: GCLOUD_RW_API_KEY
        value: "<your-grafana-cloud-api-token>"
      - name: CLUSTER_NAME
        value: ensemble
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: NODE_NAME
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
      - name: GCLOUD_FM_COLLECTOR_ID
        value: grafana-k8s-monitoring-$(CLUSTER_NAME)-$(NAMESPACE)-alloy-logs-$(NODE_NAME)
  remoteConfig:
    enabled: true
    url: https://fleet-management-prod-024.grafana.net
    auth:
      type: basic
      username: "<your-fleet-management-instance-id>"
      passwordFrom: sys.env("GCLOUD_RW_API_KEY")

alloy-receiver:
  enabled: true
  alloy:
    extraPorts:
      - name: otlp-grpc
        port: 4317
        targetPort: 4317
        protocol: TCP
      - name: otlp-http
        port: 4318
        targetPort: 4318
        protocol: TCP
      - name: zipkin
        port: 9411
        targetPort: 9411
        protocol: TCP
    extraEnv:
      - name: GCLOUD_RW_API_KEY
        value: "<your-grafana-cloud-api-token>"
      - name: CLUSTER_NAME
        value: ensemble
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: NODE_NAME
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
      - name: GCLOUD_FM_COLLECTOR_ID
        value: grafana-k8s-monitoring-$(CLUSTER_NAME)-$(NAMESPACE)-alloy-receiver-$(NODE_NAME)
  remoteConfig:
    enabled: true
    url: https://fleet-management-prod-024.grafana.net
    auth:
      type: basic
      username: "<your-fleet-management-instance-id>"
      passwordFrom: sys.env("GCLOUD_RW_API_KEY")
EOF
