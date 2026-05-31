# Sync CV from Overleaf source, build PDF, and copy to assets/cv/cv.pdf
#
# Usage:
#   .\scripts\sync-cv.ps1              # pull from Overleaf + build
#   .\scripts\sync-cv.ps1 -SkipPull      # build local cv-source/ only
#
# Prerequisites:
#   - cv-source/ cloned from Overleaf (this script clones on first run)
#   - LaTeX with latexmk (TeX Live / MiKTeX)

param(
    [switch]$SkipPull
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$CvDir = Join-Path $Root "cv-source"
$MainTex = Join-Path $CvDir "main.tex"
$BuiltPdf = Join-Path $CvDir "main.pdf"
$OutPdf = Join-Path $Root "assets\cv\cv.pdf"
$OverleafUrl = "https://git.overleaf.com/6440339541540a8edd971bfa"

function Ensure-CvSource {
    if (Test-Path $MainTex) {
        return
    }

    Write-Host "cv-source/ not found. Cloning Overleaf project..."
    git clone $OverleafUrl $CvDir
}

Ensure-CvSource

if (-not $SkipPull) {
    Write-Host "Pulling latest CV from Overleaf..."
    git -C $CvDir pull origin master
}

if (-not (Get-Command latexmk -ErrorAction SilentlyContinue)) {
    Write-Error "latexmk not found. Install TeX Live or MiKTeX, then retry."
}

Write-Host "Building CV with latexmk..."
latexmk -pdf -interaction=nonstopmode -cd $MainTex

if (-not (Test-Path $BuiltPdf)) {
    Write-Error "Build failed: $BuiltPdf was not created."
}

New-Item -ItemType Directory -Path (Split-Path $OutPdf) -Force | Out-Null
Copy-Item $BuiltPdf $OutPdf -Force

Write-Host "Done. CV copied to assets/cv/cv.pdf"
Write-Host "Next: quarto render"
