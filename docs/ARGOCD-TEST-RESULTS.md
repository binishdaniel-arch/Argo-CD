# Argo CD verification — 31 October 2026

Executed on the existing Docker Desktop Kubernetes v1.36.1 cluster (`docker-desktop`) using Helm v4.3.0. These checks used the real GitHub repository and live Kubernetes API.

| Check | Measured result |
|---|---|
| Vendored argo-helm chart 10.11.6 / Argo CD v3.5.6 | Helm lint and installation passed |
| Control-plane readiness | Controller, repo-server, API server, Redis and ApplicationSet running |
| AppProject, three Application CRs, UI Ingress | Kubernetes server-side dry-run passed |
| Adopt Lab 1 workloads in ingress-lab | All three Applications Synced and Healthy; existing app names and URLs retained |
| Argo tracking | NGINX Deployment has `lab-nginx:apps/Deployment:ingress-lab/nginx` tracking annotation |
| Manual Git change | Commit a8fc9b0 declared 3 replicas and a disposable ConfigMap; refresh produced OutOfSync while live Deployment remained at 2 |
| Manual sync | Applied the Git change and created gitops-prune-demo |
| Self-heal | With auto-sync/selfHeal enabled, manually scaling to 1 was repaired to Git's 3; rollout reached 3 ready replicas |
| Git revert + auto-sync | Revert commit 0e3ba8b restored desired/live replica count to 2 |
| Prune disabled | Removed ConfigMap template remained live; Application reported OutOfSync |
| Explicit prune sync | Deleted only the tracked disposable gitops-prune-demo ConfigMap |
| Restore manual policy | `automated.enabled=false`, prune=false, selfHeal=false confirmed live |
| Final baseline | All 3 Applications Synced/Healthy, 2 ready replicas per application |
| Existing ingress routes after adoption/recovery | NGINX, Prometheus and Grafana HTTP 200; unknown host HTTP 404 |
| Argo UI and health through ingress | `/` and `/healthz` HTTP 200 with Host argocd.lab.test |
| Authentication | Initial-admin login through ingress API succeeded; authenticated API listed the three Applications; credentials/token not printed or saved |
| PowerShell scripts | Syntax parsing passed for every .ps1 file; setup, sync, policy switching and check scripts exercised |
| HTML and diagram | 11 labs, 22 visible answers, 33 copy buttons; local links/anchors valid; SVG XML valid |
| Browser visual, interactive clipboard and optional Argo CLI | Not run; browser connection unavailable; Argo CLI not installed |

## Important discoveries and boundaries

Default Argo Ingress health remained Progressing when the original ClusterIP-only ingress controller published no address. The final controller values publish 127.0.0.1. This describes the local entry point and is not an HTTP reachability probe. The guide explicitly separates sync, health and HTTP testing.

A controller rollout ends a port-forward attached to an old controller pod. Restarting the foreground port-forward restored connectivity. An intermediate HTTP 000 was from that disconnected forward, not an app-route failure. All final route checks passed.

The baseline smoke test intentionally expects two replicas and fails during the three-replica exercise. Run it after restoring the baseline, not during scaling practice. The final sync helper additionally waits for the Deployment rollout so cached Application health cannot substitute for pod readiness.

The old three Helm release records remain frozen. Do not use them to upgrade/uninstall while Argo Applications exist. Lab 1 deploy/cleanup scripts now block during GitOps ownership. Argo itself and Traefik remain Helm-managed. The Application declarations are manually bootstrapped, not watched by an app-of-apps; changing their policy in Git also requires applying the declaration. Explicit manual-policy fields ensure reapplication resets temporary practice policy.

No workload hand-back, cascading deletion, Argo uninstall, production HA, TLS, SSO, webhook, private-repository authentication, force/replace, ApplicationSet generation or optional CLI interactions were tested. They are not claimed as validated paths. Non-cascading hand-back instructions are supplied for later student use. The lab is left installed in manual-sync mode with two application replicas; no hosts-file changes were made. Start your own port-forward and add the hosts entry from the guide to open the UI.

## Reproduce

1. Complete Lab 1; read lab2-argocd.html.
2. Run `scripts/argocd-setup.ps1`, then inspect the UI diff and run `scripts/argocd-sync.ps1`.
3. Keep the Traefik localhost port-forward open.
4. Run `scripts/argocd-check.ps1` and `scripts/smoke-test.ps1`.
5. Follow Labs 2.05–2.07 to repeat manual sync, self-healing and pruning on your own fork. End with two replicas and explicit manual policy.
