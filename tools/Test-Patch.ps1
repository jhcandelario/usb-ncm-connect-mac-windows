[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$UpstreamPath
)

$ErrorActionPreference = 'Stop'
$expectedCommit = '48d93213022dce92d518adc60c91fbbb0beab498'
$projectRoot = Split-Path -Parent $PSScriptRoot
$patch = Join-Path $projectRoot 'patches\0001-apple-05ac-1902-device-compatibility.patch'

if (-not (Test-Path -LiteralPath (Join-Path $UpstreamPath '.git'))) {
    throw "UpstreamPath is not a Git checkout: $UpstreamPath"
}

$actualCommit = (& git -C $UpstreamPath rev-parse HEAD).Trim()
if ($actualCommit -ne $expectedCommit) {
    throw "Expected upstream commit $expectedCommit but found $actualCommit."
}

& git -C $UpstreamPath apply --check $patch
if ($LASTEXITCODE -ne 0) {
    throw 'Patch validation failed.'
}

Write-Host 'Patch validation passed.' -ForegroundColor Green
