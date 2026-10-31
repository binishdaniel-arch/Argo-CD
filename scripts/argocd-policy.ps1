param([ValidateSet('Auto','Manual')][string]$Mode = 'Manual')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$path = 'gitops/applications/nginx.yaml'
$text = Get-Content $path -Raw
$value = if ($Mode -eq 'Auto') { 'true' } else { 'false' }
$text = $text -replace 'enabled: (true|false)', "enabled: $value"
$text = $text -replace 'selfHeal: (true|false)', "selfHeal: $value"
# Automatic pruning stays disabled; students explicitly prune the disposable ConfigMap.
[System.IO.File]::WriteAllText((Join-Path $PWD $path), $text, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Updated Git working file to $Mode. Review git diff, commit/push, then kubectl apply this file."
