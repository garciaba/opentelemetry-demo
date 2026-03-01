# ENSEMBLE — Contemporary Fashion E-Commerce

> A microservice-based fashion e-commerce platform, fully instrumented with
> OpenTelemetry and exporting to **Grafana Cloud** via **Grafana Alloy**.

## About

ENSEMBLE is a curated online fashion store built on top of the
[OpenTelemetry Demo](https://github.com/open-telemetry/opentelemetry-demo)
architecture. The product catalog, reviews, LLM assistant, and storefront have
been rebranded to showcase contemporary fashion items — from cashmere knitwear
and tailored blazers to leather boots and classic trench coats.

The observability stack has been migrated from the default local backends to
**Grafana Cloud**, using **Grafana Alloy** as the OpenTelemetry Collector with
native `host_info` and `spanmetrics` connectors for Application Observability
billing and RED metrics.

### Key changes from the upstream demo

- **Product catalog** — 10 fashion items replacing the original astronomy
  products, with matching SVG artwork.
- **Product reviews** — 50 fashion-themed reviews seeded into PostgreSQL.
- **LLM service** — `ensemble-llm` model serving fashion review summaries.
- **Alloy collector** — native `.alloy` config format with `host_info`,
  `spanmetrics`, and Grafana Cloud OTLP export.
- **Kubernetes** — Helm deployment script for the Grafana k8s-monitoring stack.

## Quick start

### Docker Compose (local)

```bash
# 1. Clone the ensemble branch
git clone -b ensemble https://github.com/garciaba/opentelemetry-demo.git
cd opentelemetry-demo

# 2. Fill in Grafana Cloud credentials
#    Edit .env.override with your instance ID, API token, and OTLP endpoint

# 3. Enable the Alloy collector override
cp docker-compose.ensemble.yml docker-compose.override.yml

# 4. Start everything
docker compose up
```

The storefront is available at **<http://localhost:8080/>**.

### Kubernetes

See [`kubernetes/deploy-k8s-monitoring.sh`](kubernetes/deploy-k8s-monitoring.sh)
for a Helm-based deployment of the Grafana k8s-monitoring stack.

## Architecture

ENSEMBLE is composed of 14+ microservices written in Go, .NET, Java, Node.js,
Python, Ruby, Rust, and C++. All services emit traces, metrics, and logs via
OpenTelemetry to the Grafana Alloy collector, which forwards them to Grafana
Cloud.

For full architecture details, see the
[upstream documentation](https://opentelemetry.io/docs/demo/).

## Upstream project

This fork is based on the
[OpenTelemetry Demo](https://github.com/open-telemetry/opentelemetry-demo)
project. See the upstream repo for the full vendor integration list and
community documentation.

## License

This project is licensed under the Apache 2.0 License — see [LICENSE](LICENSE)
for details.

Based on the [OpenTelemetry Demo](https://github.com/open-telemetry/opentelemetry-demo)
(Apache 2.0).
