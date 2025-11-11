# Kubernetes Wiki - Deployment and Development

This repository contains a Wiki application service (`wiki-service`) and a Helm chart (`wiki-chart`) to deploy the service on Kubernetes. The repository also includes a containerized setup for running a local `k3d` Kubernetes cluster.

---
## Table of Contents

- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Local Development (wiki-service)](#local-development-wiki-service)
  - [Run with Python](#run-with-python)
  - [Run with Docker](#run-with-docker)
- [Container Image for k3d + Tooling](#container-image-for-k3d--tooling)
- [Deploy to Kubernetes with Helm](#deploy-to-kubernetes-with-helm)
- [Configuration](#configuration)
- [Monitoring](#monitoring)
- [Cleanup](#cleanup)
- [Notes](#notes)

---

## Repository Structure

```
kubernetes-wiki-master/
├── Dockerfile                  # Image that installs k3d, kubectl, and Helm
├── start.sh                    # Entrypoint script for the k3d environment
├── wiki-chart/                 # Helm chart for deploying wiki-service
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── prometheus-deployment.yaml
│       ├── grafana-deployment.yaml
│       ├── pvc.yaml
│       ├── hpa.yaml
│       └── serviceaccount.yaml
└── wiki-service/               # FastAPI-based Wiki microservice
    ├── Dockerfile              # Dockerfile for wiki-service
    ├── app/
    │   ├── main.py
    │   ├── database.py
    │   ├── models.py
    │   ├── schemas.py
    │   └── metrics.py
    ├── pyproject.toml
    ├── uv.lock
    ├── start.sh
    └── README.md
```

---

## Prerequisites

- Docker (latest version)
- Python 3.11+ (optional, for local development)
- kubectl (configured)
- Helm v3+
- k3d, kind, or minikube (for local clusters)

---

## Local Development (wiki-service)

### Run with Python

1. Navigate to the service directory:
   ```bash
   cd wiki-service
   ```

2. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install fastapi sqlalchemy aiosqlite prometheus-client pydantic uvicorn
   ```

4. Start the application:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

5. Access the endpoints:
   - Swagger UI: http://localhost:8000/docs
   - Metrics: http://localhost:8000/metrics

---

### Run with Docker

1. Build the Docker image using the provided Dockerfile:
   ```bash
   docker build -t wiki-service:latest ./wiki-service
   ```

2. Run the container:
   ```bash
   docker run --rm -p 8000:8000 wiki-service:latest
   ```

3. Test locally:
   ```bash
   curl http://localhost:8000/
   curl http://localhost:8000/metrics
   ```

> **Note:** You do not need to use your Docker Hub username or push this image unless deploying to a remote registry. The local `wiki-service:latest` image is sufficient for testing and local clusters.

---

## Container Image for k3d + Tooling

The root-level `Dockerfile` builds an environment with `Docker-in-Docker`, `k3d`, `kubectl`, and `helm` installed. It starts a lightweight single-node Kubernetes cluster.

To build and run it:

```bash
docker build -t wiki-k3d:latest .
docker run --privileged -it -p 8000:8000 wiki-k3d:latest
```

The script `start.sh` creates a cluster named `wiki-cluster` and exposes port 8000 on your host.

---

## Deploy to Kubernetes with Helm

1. Load the locally built image into your cluster:

   **For k3d:**
   ```bash
   k3d image import wiki-service:latest -c wiki-cluster
   ```

   **For kind:**
   ```bash
   kind load docker-image wiki-service:latest
   ```

   **For minikube:**
   ```bash
   minikube image load wiki-service:latest
   ```

2. Update the Helm chart to use the local image:

   ```yaml
   image:
     repository: wiki-service
     tag: latest
     pullPolicy: IfNotPresent
   ```

3. Deploy the service using Helm:

   ```bash
   cd wiki-chart
   helm install wiki-release . --namespace wiki --create-namespace
   ```

4. Check the status:

   ```bash
   kubectl get pods,svc -n wiki
   ```

5. Access the service:

   ```bash
   kubectl port-forward svc/wiki 8000:8000 -n wiki
   ```

   Visit http://localhost:8000

---

## Configuration

Edit `wiki-chart/values.yaml` to customize:

- Replica count
- Image details (repository, tag, pullPolicy)
- Resource limits
- Service type (ClusterIP, NodePort, LoadBalancer)
- Ingress hostname
- Monitoring settings for Prometheus/Grafana

Apply changes:

```bash
helm upgrade wiki-release . -n wiki
```

---

## Monitoring

`wiki-service` exposes Prometheus metrics at `/metrics`.

To enable integrated monitoring (Prometheus + Grafana) in Helm:

```bash
helm upgrade wiki-release . -n wiki --set prometheus.enabled=true --set grafana.enabled=true
```

Access Grafana:

```bash
kubectl port-forward svc/grafana 3000:3000 -n wiki
```

Then open http://localhost:3000

---

## Cleanup

Remove all resources:

```bash
helm uninstall wiki-release -n wiki
kubectl delete namespace wiki
```

Remove local Docker images:

```bash
docker image rm wiki-service:latest wiki-k3d:latest
```

---

## Notes

- The `wiki-service` uses SQLite by default. You can modify `app/database.py` for PostgreSQL or MySQL.
- No Docker Hub username is required for local builds.
- The root `Dockerfile` provides a full `k3d` Kubernetes environment and is optional for deployment.
