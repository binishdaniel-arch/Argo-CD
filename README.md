# Ingress, understood

Open **index.html** for the full light-themed guide, diagram, copy buttons, all chart sources, and interview checkpoints after each lab. No frontend installation required.

## Quick start (PowerShell)

Docker Desktop Kubernetes must be enabled. You need kubectl, Helm 3 or 4, registry internet access, and the docker-desktop context. Run from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/deploy.ps1
kubectl port-forward -n ingress-system svc/lab-ingress-traefik 8080:80 --address 127.0.0.1
```

In a second terminal:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate.ps1
powershell -ExecutionPolicy Bypass -File scripts/smoke-test.ps1
```

Use the HTML guide for hosts-file/browser instructions, manual installation, traffic flow, troubleshooting and cleanup.

## Section 2: Argo CD and GitOps

Open **lab2-argocd.html** for 11 guided labs, 22 interview answers, and GitOps management of these same three applications. Run `powershell -ExecutionPolicy Bypass -File scripts/argocd-setup.ps1` after Lab 1. See [Argo CD test results](docs/ARGOCD-TEST-RESULTS.md).

## Scope

Three locally authored Helm charts: nginx, prometheus, grafana. Each has two replicas and a ClusterIP Service and host-based Ingress. Official Traefik chart 42.2.0 is vendored under vendor/. Grafana datasource is provisioned. Prometheus scrapes itself and Grafana. NGINX has no metrics exporter. Two independent Prometheus instances and ephemeral Grafana state are deliberate learning simplifications, not production HA. HTTP and anonymous Grafana are restricted to a localhost exercise. All images and controller chart are pinned by version tag, not immutable digest.

[Actual test evidence](docs/TEST-RESULTS.md) · [Traffic diagram](docs/architecture.svg)

## GitHub

This is a local Git repository; create an empty repository in your GitHub account, then set its URL and push. No GitHub upload is performed automatically. See the HTML guide for commands. The vendored upstream chart retains its upstream license. Your application charts and guide use the MIT license.
