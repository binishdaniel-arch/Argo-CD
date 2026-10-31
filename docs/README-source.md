# Ingress, understood — Git Bash + KillerCoda

Open **index.html** for Section 1 and **lab2-argocd.html** for Section 2. Both have a light theme, copyable Bash commands, diagrams, and visible interview answers. No frontend build or CDN is required.

Start with **environments.html** for platform-specific setup and browser access.

## Docker Desktop — Git Bash

Enable Kubernetes in Docker Desktop and install Git, kubectl and Helm. Open **Git Bash**, then:

```bash
export MSYS_NO_PATHCONV=1
kubectl config use-context docker-desktop
bash scripts/deploy.sh
kubectl port-forward -n ingress-system svc/lab-ingress-traefik 8080:80 --address 127.0.0.1
```

Keep the forward open. In a second Git Bash terminal, run `bash scripts/validate.sh` and `bash scripts/smoke-test.sh`. The guide includes Windows hosts-file instructions for local UI links.

## KillerCoda — Linux Bash

Open the [Kubernetes playground](https://killercoda.com/playgrounds/scenario/kubernetes). In its terminal:

```bash
git clone https://github.com/vrdipu/ingress-lab.git
cd ingress-lab
bash scripts/install-helm-linux.sh
export PATH="$HOME/.local/bin:$PATH"
bash scripts/deploy.sh
bash scripts/killercoda-access.sh
```

Do not select the docker-desktop context. The scripts recognize `/etc/killercoda/host`. Keep the access launcher running and open its printed URLs or Traffic / Ports 8080–8083. Generated-host Ingress rules send browser traffic through Traefik; no local hosts-file edit is needed. Use a second KillerCoda terminal for validation and exercises. These access URLs expose the ephemeral lab; use only lab credentials, never production secrets. See the platform guide for details and session limitations.

## Section 2 — Argo CD

After Lab 1:

```bash
bash scripts/argocd-setup.sh
# Restart the access forward after the controller rollout.
# Docker Desktop: the localhost port-forward above.
# KillerCoda: bash scripts/killercoda-access.sh again (now also prints Argo URL).
bash scripts/argocd-sync.sh
bash scripts/argocd-check.sh
```

Students must fork this repository to practice Git changes. Set origin to your own fork, run `bash scripts/gitops-repository.sh https://github.com/YOUR-USERNAME/ingress-lab.git`, review/commit/push the source changes, then run setup. The AppProject and all Application repoURLs must match the public fork. Do not push exercises to the shared instructor repository. Configure your Git name/email if needed; authenticate GitHub interactively when pushing without saving tokens in commands or repository files.

## Scope and ownership

Three locally authored Helm charts deploy NGINX, Prometheus and Grafana with two replicas, Services and host-based Ingress. Official Traefik 42.2.0 and community argo-helm Argo CD 10.11.6 charts are vendored. Version tags are pinned; images are not digest-pinned. Argo adopts the same Lab 1 resources. Freeze the original Helm release records during GitOps; deploy/cleanup scripts block while the lab Applications exist. Keep Argo itself and Traefik Helm-managed.

Monitoring data is temporary and replicas do not share storage. This demonstrates ingress and GitOps, not production monitoring HA. KillerCoda access Ingresses are runtime conveniences outside the three Argo Applications; their generated hostnames must not be committed to Git.

Bash scripts are the main workflow. Older `.ps1` files remain optional compatibility helpers and are not required for these guides. Scripts use LF endings; invoke them with `bash scripts/<name>.sh`.

[Original ingress test evidence](docs/TEST-RESULTS.md) · [Argo CD evidence](docs/ARGOCD-TEST-RESULTS.md) · [Bash/KillerCoda portability evidence](docs/PORTABILITY-TEST-RESULTS.md)

The local Docker Desktop cluster has been tested. The portability report distinguishes locally executed Git Bash/Linux checks from any live KillerCoda checks; do not infer an external playground run from local tests.

## GitHub

Repository: https://github.com/vrdipu/ingress-lab. Download or clone it; open the HTML guides locally. Create your own fork for student GitOps exercises. Your charts and guide use MIT; vendored charts retain their upstream licenses.
