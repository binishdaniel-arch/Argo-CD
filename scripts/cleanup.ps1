$ErrorActionPreference = 'Stop'
$gitopsApps = ''
$applicationCrd = kubectl get crd applications.argoproj.io --ignore-not-found -o name
if ($applicationCrd) { $gitopsApps = kubectl get applications.argoproj.io -n argocd -o name --ignore-not-found }
if ($gitopsApps -match 'application.argoproj.io/lab-(nginx|prometheus|grafana)') { throw 'Argo CD now manages these apps. Follow Lab 2 hand-back steps before running Helm deployment or cleanup.' }
foreach ($app in @('nginx','prometheus','grafana')) {
  helm uninstall $app -n ingress-lab
  if ($LASTEXITCODE -ne 0) { throw "Uninstall failed: $app" }
}
helm uninstall lab-ingress -n ingress-system
if ($LASTEXITCODE -ne 0) { throw 'Controller uninstall failed' }
# Namespaces intentionally retained. No unrelated workloads are deleted.
