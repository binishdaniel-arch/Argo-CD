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

## Section 2 ? Argo CD, taught from the beginning

Open **lab2-argocd.html** and follow one simple sequence. After installation, the new Components and Services lesson explains the architecture, observed Service ports, reconciliation flow and troubleshooting. [Component notes](docs/ARGOCD-COMPONENTS.md) include a diagram and 10 additional interview answers (32 total in Lab 2).

1. Deploy Argo CD first. No ingress or Lab 1 installation is required.
2. Open the Argo CD URL and sign in.
3. Read/create the demo Deployment and Service manifests.
4. Connect your public Git repository and understand every Application field.
5. Apply only the Application; Argo automatically deploys the workload.
6. Push a replica or pod-configuration change and watch it reconcile in the UI.
7. Demonstrate self-healing of a manual cluster edit.
8. Install the CLI and use list/get/refresh/wait/history.

```bash
bash scripts/argocd-install.sh
bash scripts/argocd-ui.sh
```

The helper prints http://localhost:8090 on Docker Desktop or the generated port-8090 URL on KillerCoda. Keep it running and use another terminal for the guide. The beginner demo uses `gitops/demo/application.yaml` watching `gitops/demo/manifests`, deployed into its own `argocd-demo` namespace. It starts with auto-sync and self-heal enabled. The original Lab 1 chart adoption is optional after the main demo; the older argocd-setup.sh helper is not the beginner entry point.

Students should fork this repository before Git-change exercises. Update origin and run `bash scripts/gitops-repository.sh https://github.com/YOUR-USERNAME/ingress-lab.git`; review, commit and push the source changes. This updates the demo Application and the optional chart Applications/project. Private credentials never belong in Git. Argo can read a public repository without a credential; Settings ? Repositories lets you show that connection explicitly.

[Beginner demo test evidence](docs/ARGOCD-BEGINNER-TEST-RESULTS.md)

## Scope and ownership

Three locally authored Helm charts deploy NGINX, Prometheus and Grafana with two replicas, Services and host-based Ingress. Official Traefik 42.2.0 and community argo-helm Argo CD 10.11.6 charts are vendored. Version tags are pinned; images are not digest-pinned. Argo adopts the same Lab 1 resources. Freeze the original Helm release records during GitOps; deploy/cleanup scripts block while the lab Applications exist. Keep Argo itself and Traefik Helm-managed.

Monitoring data is temporary and replicas do not share storage. This demonstrates ingress and GitOps, not production monitoring HA. KillerCoda access Ingresses are runtime conveniences outside the three Argo Applications; their generated hostnames must not be committed to Git.

Bash scripts are the main workflow. Older `.ps1` files remain optional compatibility helpers and are not required for these guides. Scripts use LF endings; invoke them with `bash scripts/<name>.sh`.

[Original ingress test evidence](docs/TEST-RESULTS.md) · [Argo CD evidence](docs/ARGOCD-TEST-RESULTS.md) · [Bash/KillerCoda portability evidence](docs/PORTABILITY-TEST-RESULTS.md)

The local Docker Desktop cluster has been tested. The portability report distinguishes locally executed Git Bash/Linux checks from any live KillerCoda checks; do not infer an external playground run from local tests.

## GitHub

Repository: https://github.com/vrdipu/ingress-lab. Download or clone it; open the HTML guides locally. Create your own fork for student GitOps exercises. Your charts and guide use MIT; vendored charts retain their upstream licenses.
