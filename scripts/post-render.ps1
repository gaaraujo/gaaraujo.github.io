# Legacy wrapper — post-render is scripts/post-render.sh (cross-platform via bash).
$bash = Get-Command bash -ErrorAction SilentlyContinue
if ($bash) {
  & bash (Join-Path $PSScriptRoot "post-render.sh")
} else {
  New-Item -ItemType File -Path (Join-Path $PSScriptRoot "..\docs\.nojekyll") -Force | Out-Null
}
