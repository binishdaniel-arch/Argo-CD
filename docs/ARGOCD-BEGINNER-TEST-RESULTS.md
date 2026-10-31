# Beginner Argo CD demo — local verification, 31 October 2026

Lab 2 was rewritten around one install-first, automatic-deployment workflow. The required demo is isolated in `argocd-demo`; the original Lab 1 chart adoption is optional afterward.

| Check | Actual result |
|---|---|
| Standalone Argo CD installer | PASS on Docker Desktop Kubernetes v1.36.1, Helm v4.3.0; control plane ready before demo Application creation |
| UI access helper | PASS; localhost:8090 forwards directly to argocd-server; no ingress or hosts entry required |
| Initial authentication | PASS through the HTTP session API using the local initial-admin credential; credentials not printed or committed |
| Apply only gitops/demo/application.yaml | PASS; Argo created argocd-demo namespace, Deployment, Service and two ready pods automatically |
| Git-based replica demonstration | Commit `1b93a05` changed desired replicas 2 to 3; automatic sync reached 3 ready replicas, with no manual sync or workload apply |
| Git-based configuration demonstration | Commit `fe76ac9` changed the pod-template label v1 to v2; Argo automatically rolled out new pods showing v2 |
| Baseline restoration | Commit `f4d06aa` restored two replicas and label v1; automatic sync completed |
| Live drift / self-heal | Manually scaled the demo Deployment to 1; Argo restored 2 ready replicas without a new Git change |
| Demo Application and workload YAML | Kubernetes server-side dry-run passed |
| Windows CLI installer | Official v3.5.6 executable downloaded, published CLI checksum verified, version executed |
| Linux CLI installer | Same version downloaded and checksum verified in isolated Alpine 3.22 + Bash; version/help executed |
| Authenticated CLI operations | PASS: repo add/list, app list/get, get --refresh, wait --sync --health, history using the local API and temporary token authentication |
| CLI login and saved connection settings | PASS: real CLI login using password on stdin, then all five guide commands without repeating connection flags. Temporary CLI config removed afterward. Interactive browser/keyboard entry was not automated. |
| Documentation checks | PASS: 8 sequential beginner steps, 22 visible interview answers, 24 copy buttons, links/anchors and SVG XML valid |
| Live KillerCoda/browser visual/clipboard checks | Not executed; platform helpers and Linux CLI were validated locally, not in a connected external playground |

## What proves the automatic loop

The workload YAML was not applied manually and no manual Argo sync was requested for the beginner demo. Only its Application was applied. Subsequent replica/configuration commits were pushed to the watched GitHub main branch and reconciled automatically. The final demo Deployment has two ready replicas and demo-version v1. The Application has automated.enabled=true, selfHeal=true and prune=false.

The initial direct wait for a Deployment ran before the automatically created namespace existed. The documented check helper waits for the Application to become Synced first, then checks Deployment replicas, rollout and health; this completed successfully for initial deployment and both replica states.

## Intended teaching order

1. Install Argo CD only.
2. Open its URL and log in.
3. Read/create Deployment and Service manifests in Git.
4. Connect the public repository in the UI and explain the Application source/destination/policy.
5. Apply only the Application and watch automatic deployment.
6. Commit/push replica and configuration changes and observe the resource tree.
7. Show live-drift self-healing.
8. Learn login plus five CLI operations.

Public repository access was verified using the authenticated CLI repo add/list operations; the browser Connect Repo clicks were not automated. A public source can also be fetched directly from the Application repoURL without a separately registered repository. Student push credentials and Argo repository read access are separate concerns.

## Limits and final state

The existing cluster already had Argo CD and the original three Lab 1 workloads, so the installer was exercised as an upgrade. The new demo namespace/resources did not exist beforehand and were automatically created by Argo. A completely empty-cluster install, live KillerCoda session, interactive browser/password entry and optional three-chart handover were not repeated in this test. Historical handover and platform evidence remains in the other reports.

The original lab-nginx/lab-prometheus/lab-grafana Applications are retained. Demo and original workloads remain installed. No finalizer was added to demo-nginx; no cascading deletion was tested. Tokens used for API-driven CLI testing were passed through process environments. The separate real CLI login test wrote a temporary config, verified all five commands, then removed it. No password or token was printed or committed. Downloaded test binaries are under ignored .lab-runtime/, not committed. Start `bash scripts/argocd-ui.sh` to reopen the Argo URL.

The CLI HTTP login test exposed an unnecessary TLS probe which reset the local port-forward. The final login command includes `--skip-test-tls`; the UI forward was restarted, login succeeded, and all five commands then worked using the saved connection settings. This option is for the lab HTTP endpoint, not for bypassing certificate checks on production HTTPS.
