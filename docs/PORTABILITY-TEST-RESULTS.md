# Git Bash / KillerCoda portability verification — 31 October 2026

The primary student workflow now uses Bash: Git Bash on Windows with Docker Desktop, or Linux Bash in the KillerCoda Kubernetes playground. Both HTML sections link to environments.html for setup, fork configuration and browser access.

| Check | Executed result |
|---|---|
| Every .sh file parsed by real Git Bash | PASS |
| Bash Helm lint + Kubernetes server dry-run | PASS for all 3 app charts, controller charts, Application/Project and UI Ingress manifests |
| Bash one-time Argo sync helper | PASS for all 3 Applications |
| Bash setup idempotency and ownership guard | PASS: existing Argo setup reinstalled cleanly; Helm deployment correctly refused during GitOps ownership |
| Bash status helper | PASS: all Synced/Healthy, 2 ready replicas each |
| Bash ingress smoke helper | PASS: 3 HTTP 200 routes and unknown-host HTTP 404 |
| Generated-host route renderer | All 4 manifests accepted by Kubernetes server dry-run |
| Generated-host routing through real local Traefik | HTTP 200 for NGINX, Prometheus, Grafana and Argo CD health; temporary synthetic test routes removed afterward |
| Isolated Linux (Alpine 3.22 + Bash) | All scripts parse; official Linux Helm v4.3.0 downloaded and checksum verified |
| Linux chart lint/render | PASS for vendored controllers and all three app charts |
| Linux policy and fork-source helper | PASS in a disposable copy; auto/manual toggles and all project/Application repository URLs updated correctly |
| Live KillerCoda session / actual platform proxy / browser clipboard | NOT EXECUTED: no connected live playground/browser session was available |

## Platform-specific behavior

The access launcher uses KillerCoda's documented `/etc/killercoda/host` template. Ports 8080–8083 generate separate browser hostnames, each mapped to an additional Ingress. All four forwards target the existing Traefik Service on port 80, preserving the ingress learning path. These runtime Ingresses are intentionally outside the three Argo Applications; generated URLs must not be committed to reusable charts. Argo's external URL is patched only for the ephemeral session. The launcher requires the actual KillerCoda marker, stays in the foreground, records forward logs under ignored .lab-runtime/, and stops its own child processes on exit.

Local generated-host routing tests used synthetic test hostnames on the existing Docker Desktop cluster. They demonstrate matching hosts and backend routes, not a live KillerCoda proxy integration. Linux validation ran in an isolated Docker container, not the remote playground. The KillerCoda UI and current scenario resources/session lifetime must still be checked in an actual student session. The guide links the official platform documentation and provides restart/troubleshooting steps.

## Issues found and fixed

- Windows-generated CRLF endings were rejected by Linux Bash. All .sh files are now LF, and .gitattributes preserves LF in future clones.
- Disabling Git Bash path conversion is necessary for kubectl paths, but native Windows curl then cannot use `/dev/null`. The smoke helper now selects `NUL` on Windows and `/dev/null` on Linux; the final Windows HTTP checks passed.
- Docker Desktop context checks do not apply to KillerCoda. Scripts detect the playground marker and retain its supplied context.
- KillerCoda's browser hostname differs from .lab.test. The generated-host access routes fix that without bypassing Traefik; the original host-based curl exercises still work inside the remote terminal.

## Reproduce

Read environments.html. On Docker Desktop, open Git Bash and run `bash scripts/validate.sh`, `bash scripts/argocd-sync.sh`, `bash scripts/argocd-check.sh`, then the localhost forward and `bash scripts/smoke-test.sh`. On a clean KillerCoda Kubernetes playground, clone the repository, install Helm if needed, run deploy.sh, then killercoda-access.sh. Follow Section 2 after pointing GitOps sources at your own public fork.

Older PowerShell helpers and their historical test reports remain for compatibility. They are not required by the Bash-first student guides. No application hand-back, cleanup/uninstall or live external playground session is claimed as tested in this portability update.
