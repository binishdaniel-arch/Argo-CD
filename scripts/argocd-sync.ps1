param([ValidateSet('nginx','prometheus','grafana','all')][string]$App = 'all')
$ErrorActionPreference = 'Stop'
if ((kubectl config current-context) -ne 'docker-desktop') { throw 'Select docker-desktop first' }
$apps = if ($App -eq 'all') { @('nginx','prometheus','grafana') } else { @($App) }
foreach ($name in $apps) {
  $application = "lab-$name"
  $requestId = 'lab-' + [guid]::NewGuid().ToString()
  # Operation field is Argo CD's native one-time sync request. No CLI installation needed.
  $patchFile = Join-Path ([System.IO.Path]::GetTempPath()) ("argocd-sync-" + [guid]::NewGuid().ToString() + '.json')
  try {
    @{operation=@{initiatedBy=@{username=$requestId};sync=@{prune=$false;syncStrategy=@{hook=@{}}}}} | ConvertTo-Json -Depth 8 | Set-Content -Encoding ascii $patchFile
    kubectl patch application $application -n argocd --type merge --patch-file $patchFile
    if ($LASTEXITCODE -ne 0) { throw "Sync request failed: $application" }
    $deadline = (Get-Date).AddMinutes(5)
    do {
      $raw = kubectl get application $application -n argocd -o json
      if ($LASTEXITCODE -ne 0) { throw "Cannot read sync state: $application" }
      $state = ($raw | ConvertFrom-Json).status.operationState
      $ours = $state.operation.initiatedBy.username -eq $requestId
      if ($ours -and $state.phase -in @('Failed','Error')) { throw "Sync failed: $($state.message)" }
      if ($ours -and $state.phase -eq 'Succeeded') { break }
      Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $deadline)
    if (-not ($ours -and $state.phase -eq 'Succeeded')) { throw "Sync timed out: $application" }
    kubectl wait application/$application -n argocd --for=jsonpath='{.status.sync.status}'=Synced --timeout=120s
    if ($LASTEXITCODE -ne 0) { throw "Not Synced: $application" }
    kubectl rollout status "deployment/$name" -n ingress-lab --timeout=180s
    if ($LASTEXITCODE -ne 0) { throw "Deployment rollout failed: $name" }
    kubectl wait application/$application -n argocd --for=jsonpath='{.status.health.status}'=Healthy --timeout=180s
    if ($LASTEXITCODE -ne 0) { throw "Not Healthy: $application" }
  } finally { Remove-Item -LiteralPath $patchFile -ErrorAction SilentlyContinue }
}
