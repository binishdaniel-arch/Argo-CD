$ErrorActionPreference = 'Stop'
foreach ($name in @('nginx','prometheus','grafana')) {
  $raw = kubectl get application "lab-$name" -n argocd -o json
  if ($LASTEXITCODE -ne 0) { throw "Cannot read lab-$name" }
  $app = $raw | ConvertFrom-Json
  if ($app.status.sync.status -ne 'Synced' -or $app.status.health.status -ne 'Healthy') { throw "lab-$name is not Synced/Healthy" }
  $ready = kubectl get deployment $name -n ingress-lab -o jsonpath='{.status.readyReplicas}'
  if ($LASTEXITCODE -ne 0 -or $ready -ne '2') { throw "$name does not have two ready replicas" }
  Write-Host "PASS lab-$name : Synced, Healthy, two ready pods; revision $($app.status.sync.revision)"
}
