# Local verification — 31 October 2026

Executed against the user's Docker Desktop Kubernetes cluster, context `docker-desktop`, Kubernetes v1.36.1, Helm v4.3.0. Real cluster tests, not just template rendering.

| Check | Actual result |
|---|---|
| Official Traefik 42.2.0 chart lint with repository values | PASS |
| NGINX, Prometheus, Grafana `helm lint --strict` | PASS for all three |
| Helm rendering and Kubernetes server-side dry-run | PASS for all three |
| Controller Helm deployment with `--wait` | PASS, 2/2 ready |
| Three application Helm deployments with `--wait` | PASS, each 2/2 ready |
| NGINX ingress `/`, Host nginx.lab.test | HTTP 200 |
| Prometheus ingress `/-/ready` | HTTP 200 |
| Grafana ingress `/api/health` | HTTP 200 |
| Unknown ingress host | HTTP 404 |
| Prometheus `/api/v1/query?query=up` | success; prometheus=1, grafana=1 |
| Grafana `/api/datasources` | default Prometheus datasource at http://prometheus:9090 |
| Delete one NGINX pod; wait for rollout | PASS, returned to 2/2 |
| Repeat HTTP smoke tests after recovery | PASS all four checks |
| HTML structural checks and SVG XML | PASS; local links, anchors, copy-button markup |
| Browser visual and clipboard interaction checks | NOT RUN: browser/native computer-use connection unavailable |

## Reproduce

Run scripts/deploy.ps1, start the port-forward in the HTML guide, then run scripts/validate.ps1 and scripts/smoke-test.ps1 in another terminal. The live smoke test checks two ready replicas for each application and the three positive and one negative ingress routes. Guide structural checks: `python scripts/check-guide.py`.

Server dry-run emitted expected last-applied-configuration warnings because Helm manages the resources; dry-run did not persist those annotations. Helm recommended application chart icons; no lint failures occurred. Traefik 42 changed the old logs values schema; the final values use a supported additionalArguments setting and passed deployment.

Docker CLI daemon access was denied in the sandbox; kubectl successfully deployed real containers to Docker Desktop Kubernetes. No Docker CLI build was needed. Image pull and startup succeeded for every workload.

Lab releases are left installed for exploration. Port-forward was used only for testing; start your own foreground port-forward using the guide. Cleanup script is supplied but was not executed, so the working lab remains available. Hosts-file changes were not made. Browser layout and copy behavior are implemented but not claimed as interactively tested. No TLS, durable storage, production HA, or load/stress tests are claimed.
