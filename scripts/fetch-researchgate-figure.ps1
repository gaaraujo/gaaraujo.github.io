# Download a ResearchGate publication figure for local use in News / site assets.
# Usage: .\scripts\fetch-researchgate-figure.ps1 -Url "<RG figure URL>" -Out "assets/images/publications/name.jpg"
param(
    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $true)]
    [string]$Out
)

$OutDir = Split-Path -Parent $Out
if ($OutDir -and -not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
}

$Headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Referer"    = "https://www.researchgate.net/"
}

Invoke-WebRequest -Uri $Url -Headers $Headers -OutFile $Out -UseBasicParsing
Write-Host "Saved $($Out) ($((Get-Item $Out).Length) bytes)"
