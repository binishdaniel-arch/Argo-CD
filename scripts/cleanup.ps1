$ErrorActionPreference = 'Stop'
foreach ($app in @('nginx','prometheus','grafana')) {
  helm uninstall $app -n ingress-lab
  if ($LASTEXITCODE -ne 0) { throw "Uninstall failed: $app" }
}
helm uninstall lab-ingress -n ingress-system
if ($LASTEXITCODE -ne 0) { throw 'Controller uninstall failed' }
# Namespaces intentionally retained. No unrelated workloads are deleted.
