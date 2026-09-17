[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$SourceRoot
)

$ErrorActionPreference = 'Stop'

$solution = Join-Path $SourceRoot 'usbncm.sln'
$msbuild = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\amd64\MSBuild.exe'
$wdkRoot = 'C:\Program Files (x86)\Windows Kits\10\'

foreach ($requiredPath in @(
    $solution,
    $msbuild,
    (Join-Path $wdkRoot 'Include\10.0.22000.0\km\ntddk.h'),
    (Join-Path $wdkRoot 'Include\10.0.22000.0\km\netcx\kmdf\adapter\2.2\netadaptercx.h')
)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required build input was not found: $requiredPath"
    }
}

& $msbuild $solution `
    '/t:Rebuild' `
    '/p:Configuration=Release' `
    '/p:Platform=x64' `
    '/p:WindowsTargetPlatformVersion=10.0.22000.0' `
    '/p:LatestTargetPlatformVersion=10.0.22000.0' `
    "/p:WDKContentRoot=$wdkRoot" `
    '/p:WDKBuildFolder=.' `
    '/p:VisualStudioVersion=16.0' `
    '/p:NETADAPTER_VERSION_MINOR=2' `
    '/p:SkipPackageVerification=true' `
    '/p:SignMode=Off' `
    '/p:ApiValidator_Enable=false' `
    '/p:DriverCatalog_Enable=false' `
    '/m'

if ($LASTEXITCODE -ne 0) {
    throw "Build failed with exit code $LASTEXITCODE."
}

Write-Host 'Build succeeded. Output is unsigned and must not be installed as a release package.'
