$ErrorActionPreference = 'Stop'
foreach ($app in @('nginx','prometheus','grafana')) {
  $ready = kubectl get deployment $app -n ingress-lab -o jsonpath='{.status.readyReplicas}'
  if ($ready -ne '2') { throw "$app needs two ready replicas; found $ready" }
  $path = switch ($app) { 'prometheus' { '/-/ready' } 'grafana' { '/api/health' } default { '/' } }
  $code = curl.exe --silent --output NUL --write-out '%{http_code}' -H "Host: $app.lab.test" "http://127.0.0.1:8080$path"
  if ($LASTEXITCODE -ne 0 -or $code -ne '200') { throw "$app route failed: HTTP $code. Keep the port-forward terminal open." }
  Write-Host "PASS $app : two ready replicas; ingress HTTP $code"
}
$code = curl.exe --silent --output NUL --write-out '%{http_code}' -H 'Host: missing.lab.test' http://127.0.0.1:8080/
if ($code -ne '404') { throw "Unknown host should return 404, got $code" }
Write-Host 'PASS unmatched host: HTTP 404'
