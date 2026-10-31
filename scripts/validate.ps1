$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
foreach ($app in @('nginx','prometheus','grafana')) {
  helm lint "./charts/$app" --strict
  if ($LASTEXITCODE -ne 0) { throw "Lint failed: $app" }
  helm template $app "./charts/$app" -n ingress-lab | kubectl apply --dry-run=server -n ingress-lab -f -
  if ($LASTEXITCODE -ne 0) { throw "Server validation failed: $app. Deploy first to create the namespace." }
}
