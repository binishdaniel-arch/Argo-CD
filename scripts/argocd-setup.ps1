$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Run-Checked { param([scriptblock]$Command) & $Command; if ($LASTEXITCODE -ne 0) { throw "Command failed: $Command" } }
if ((kubectl config current-context) -ne 'docker-desktop') { throw 'Select docker-desktop first' }
Run-Checked { kubectl get namespace ingress-lab }
Run-Checked { kubectl get ingressclass traefik }
# Publish the local entry address so default Argo Ingress health can become Healthy.
Run-Checked { helm upgrade --install lab-ingress ./vendor/traefik-42.2.0.tgz -n ingress-system -f controller-values.yaml --wait --timeout 5m }
Run-Checked { helm upgrade --install argocd ./vendor/argo-cd-10.11.6.tgz -n argocd --create-namespace -f gitops/argocd-values.yaml --wait --timeout 10m }
Run-Checked { kubectl apply -f gitops/argocd-ingress.yaml }
Run-Checked { kubectl apply -f gitops/bootstrap/project.yaml }
Run-Checked { kubectl apply -f gitops/applications/ }
Write-Host 'Applications start in manual mode. Open lab2-argocd.html before syncing.'
