$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Run-Checked { param([scriptblock]$Command) & $Command; if ($LASTEXITCODE -ne 0) { throw "Command failed: $Command" } }
$context = kubectl config current-context
if ($context -ne 'docker-desktop') { throw "Select docker-desktop context first; current context: $context" }
Run-Checked { helm upgrade --install lab-ingress ./vendor/traefik-42.2.0.tgz -n ingress-system --create-namespace -f controller-values.yaml --wait --timeout 5m }
foreach ($app in @('nginx','prometheus','grafana')) {
  Run-Checked { helm upgrade --install $app "./charts/$app" -n ingress-lab --create-namespace --wait --timeout 5m }
}
Run-Checked { kubectl get pods,svc,ingress -n ingress-lab }
