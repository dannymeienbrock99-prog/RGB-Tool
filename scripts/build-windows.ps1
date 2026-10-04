[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$NodeVersion = '24.19.0'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $IsWindows) { throw 'This build requires Windows x64.' }
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$appRoot = Join-Path $RepositoryRoot 'aura-rgb'
$installerRoot = Join-Path $RepositoryRoot 'installer'
$artifacts = Join-Path $RepositoryRoot 'artifacts'
$buildRoot = Join-Path $RepositoryRoot ('.build/' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $artifacts, $buildRoot -Force | Out-Null

function Invoke-Checked([string]$Program, [string[]]$Arguments) {
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed with exit code $LASTEXITCODE." }
}

function Download-Verified([string]$Uri, [string]$Destination, [string]$Sha256) {
    Invoke-WebRequest -Uri $Uri -OutFile $Destination -MaximumRedirection 10
    $actual = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash
    if ($actual -ne $Sha256) { throw "SHA256 verification failed for $(Split-Path -Leaf $Destination)." }
}

function Copy-PayloadItem([string]$RelativePath, [string]$PayloadRoot) {
    $source = Join-Path $appRoot $RelativePath
    $destination = Join-Path $PayloadRoot $RelativePath
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing payload: $RelativePath" }
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
}

$package = Get-Content -LiteralPath (Join-Path $appRoot 'package.json') -Raw | ConvertFrom-Json
$version = [string]$package.version
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'Expected a stable semantic version in package.json.' }
$shortVersion = if ($version.EndsWith('.0')) { $version.Substring(0, $version.Length - 2) } else { $version }
$innoSource = Get-Content -LiteralPath (Join-Path $installerRoot 'PRISM.iss') -Raw
if ($innoSource -notmatch ('#define AppVersion "' + [regex]::Escape($version) + '"')) {
    throw 'Installer and package.json versions must agree.'
}

# setup-node obtains this exact runtime from the official Node.js distributions.
$nodeExecutable = (Get-Command node.exe -ErrorAction Stop).Source
$actualNodeVersion = (& $nodeExecutable --version).Trim()
if ($actualNodeVersion -ne "v$NodeVersion") { throw "Expected Node v$NodeVersion; found $actualNodeVersion." }
if ((& $nodeExecutable -p 'process.arch').Trim() -ne 'x64') { throw 'Expected an x64 Node runtime.' }
New-Item -ItemType Directory -Path (Join-Path $appRoot 'runtime') -Force | Out-Null
Copy-Item -LiteralPath $nodeExecutable -Destination (Join-Path $appRoot 'runtime/node.exe') -Force
if (-not (Test-Path -LiteralPath (Join-Path $appRoot 'runtime/Node-LICENSE.txt'))) {
    throw 'The bundled Node.js license is required.'
}

$windowsSdkZip = Join-Path $buildRoot 'windows-sdk.zip'
$webViewZip = Join-Path $buildRoot 'webview2.zip'
Download-Verified 'https://api.nuget.org/v3-flatcontainer/microsoft.windows.sdk.net.ref/10.0.26100.57/microsoft.windows.sdk.net.ref.10.0.26100.57.nupkg' $windowsSdkZip 'EAA0E3B938319F75BEAC5C046C84EF57212C2743E9263E0DB33B2019AB70B524'
Download-Verified 'https://api.nuget.org/v3-flatcontainer/microsoft.web.webview2/1.0.4258.31/microsoft.web.webview2.1.0.4258.31.nupkg' $webViewZip '56F7F4B8BF9AEE4B8EFEFBBDD4F67D5F74EBD1B100ED0806DA71BF76AF481AA9'
$windowsSdk = Join-Path $buildRoot 'windows-sdk'
$webViewSdk = Join-Path $buildRoot 'webview2'
Expand-Archive -LiteralPath $windowsSdkZip -DestinationPath $windowsSdk
Expand-Archive -LiteralPath $webViewZip -DestinationPath $webViewSdk
$windowsSdkReferences = Join-Path $windowsSdk 'lib/net8.0'
$nugetConfig = Join-Path $buildRoot 'NuGet.Config'
[IO.File]::WriteAllText($nugetConfig, '<configuration><packageSources><clear /><add key="nuget.org" value="https://api.nuget.org/v3/index.json" /></packageSources></configuration>', [Text.UTF8Encoding]::new($false))
foreach ($required in @(
    (Join-Path $windowsSdkReferences 'Microsoft.Windows.SDK.NET.dll'),
    (Join-Path $windowsSdkReferences 'WinRT.Runtime.dll'),
    (Join-Path $webViewSdk 'lib/net462/Microsoft.Web.WebView2.Core.dll'),
    (Join-Path $webViewSdk 'lib/net462/Microsoft.Web.WebView2.WinForms.dll'),
    (Join-Path $webViewSdk 'runtimes/win-x64/native/WebView2Loader.dll')
)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required SDK file is missing: $required" }
}

Push-Location -LiteralPath $appRoot
try {
    Invoke-Checked 'npm.cmd' @('ci', '--no-audit', '--no-fund')
    # The test suite uses fixture providers; it does not access or write physical RGB devices.
    Invoke-Checked 'npm.cmd' @('test')
    Invoke-Checked 'npm.cmd' @('run', 'build')
} finally { Pop-Location }

$nativeProject = Join-Path $appRoot 'native/Prism.WindowsLighting.csproj'
$nativePublish = Join-Path $buildRoot 'native-publish'
$nativeBuild = Join-Path $buildRoot 'native-build/'
$nativeIntermediate = Join-Path $buildRoot 'native-obj/'
Push-Location -LiteralPath (Join-Path $appRoot 'native')
try {
    Invoke-Checked 'dotnet' @(
        'publish', $nativeProject, '--configuration', 'Release', '--runtime', 'win-x64',
        '--self-contained', 'true', '--output', $nativePublish,
        "-p:WindowsSdkReferencePath=$windowsSdkReferences", "-p:WebViewSdkPath=$webViewSdk",
        "-p:BaseOutputPath=$nativeBuild", "-p:BaseIntermediateOutputPath=$nativeIntermediate",
        "-p:RestoreConfigFile=$nugetConfig",
        '-p:RestoreSources=https://api.nuget.org/v3/index.json'
    )
} finally { Pop-Location }
$nativeBin = Join-Path $appRoot 'native/bin'
New-Item -ItemType Directory -Path $nativeBin -Force | Out-Null
foreach ($name in @('PRISM-Lighting.exe', 'WebView2Loader.dll')) {
    $source = Join-Path $nativePublish $name
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing native build output: $name" }
    Copy-Item -LiteralPath $source -Destination (Join-Path $nativeBin $name) -Force
}

# Install the pinned compiler in an isolated build directory; never install PRISM during CI.
$innoInstaller = Join-Path $buildRoot 'innosetup-6.7.3.exe'
Download-Verified 'https://github.com/jrsoftware/issrc/releases/download/is-6_7_3/innosetup-6.7.3.exe' $innoInstaller '9C73C3BAE7ED48D44112A0F48E66742C00090BDB5BEF71D9D3C056C66E97B732'
$innoHome = Join-Path $buildRoot 'inno'
$compilerInstall = Start-Process -FilePath $innoInstaller -ArgumentList @(
    '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-', '/CURRENTUSER', "/DIR=`"$innoHome`""
) -WindowStyle Hidden -Wait -PassThru
if ($compilerInstall.ExitCode -ne 0) { throw "Inno Setup installation failed: $($compilerInstall.ExitCode)" }
$iscc = Join-Path $innoHome 'ISCC.exe'
if (-not (Test-Path -LiteralPath $iscc)) { throw 'Inno Setup compiler was not installed.' }
$installerName = "PRISM-Setup-$shortVersion.exe"
Invoke-Checked $iscc @("/O$artifacts", "/FPRISM-Setup-$shortVersion", (Join-Path $installerRoot 'PRISM.iss'))
if (-not (Test-Path -LiteralPath (Join-Path $artifacts $installerName))) { throw 'Installer output is missing.' }

$payload = Join-Path $buildRoot 'portable/PRISM-RGB'
New-Item -ItemType Directory -Path $payload -Force | Out-Null
foreach ($item in @(
    'dist', 'server', 'runtime', 'licenses', 'native/licenses',
    'native/bin/PRISM-Lighting.exe', 'native/bin/WebView2Loader.dll',
    'PRISM-starten.cmd', 'README.md', 'INSTALLATION.txt'
)) { Copy-PayloadItem $item $payload }
Copy-Item -LiteralPath (Join-Path $installerRoot 'PRISM.ico') -Destination (Join-Path $payload 'PRISM.ico')
$portableZip = Join-Path $artifacts 'PRISM-RGB-Windows.zip'
if (Test-Path -LiteralPath $portableZip) { throw 'Portable output already exists; use a clean output directory.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory((Split-Path -Parent $payload), $portableZip, [IO.Compression.CompressionLevel]::Optimal, $false)
$zip = [IO.Compression.ZipFile]::OpenRead($portableZip)
try {
    $zipNames = @($zip.Entries | ForEach-Object { $_.FullName.Replace('\', '/') })
    foreach ($entry in @(
        'PRISM-RGB/PRISM-starten.cmd', 'PRISM-RGB/runtime/node.exe',
        'PRISM-RGB/dist/pc-base.png', 'PRISM-RGB/dist/pc-msi.png', 'PRISM-RGB/dist/pc-asus.png',
        'PRISM-RGB/native/bin/PRISM-Lighting.exe',
        'PRISM-RGB/native/bin/WebView2Loader.dll'
    )) { if ($entry -notin $zipNames) { throw "Portable archive is missing: $entry" } }
    if ($zipNames | Where-Object { $_ -match '/(node_modules|\.git|\.build|work)/' }) {
        throw 'Portable archive contains build-only files.'
    }
} finally { $zip.Dispose() }

$hashLines = @($installerName, 'PRISM-RGB-Windows.zip') | ForEach-Object {
    $hash = (Get-FileHash -LiteralPath (Join-Path $artifacts $_) -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $_"
}
[IO.File]::WriteAllLines((Join-Path $artifacts 'SHA256SUMS.txt'), $hashLines, [Text.UTF8Encoding]::new($false))
$releaseNotes = @"
PRISM RGB Studio $shortVersion fuer Windows 10/11 x64.

- 14 RGB-Effekte, acht Szenen und frei einstellbare Farben, Helligkeit und passende Effektregler.
- MSI- und ASUS-Mainboarddesign in der PC-Vorschau, automatisch aus den Windows-Mainboarddaten gewaehlt. Der erkannte Modellname steht unter dem Hersteller-Symbolbild.
- Automatische Windows-Geraeteliste mit Namen und Herstelleruebersicht.
- RGB-Steuerung ueber kompatible Windows-LampArray-Geraete und die optionale offizielle Corsair-iCUE-Schnittstelle.
- Stream Deck und Elgato werden nur angezeigt und sind von der RGB-Steuerung ausgeschlossen.
- OpenRGB wird nicht benoetigt. Die Corsair-SDK-DLL wird nach Lizenzzustimmung separat vom Hersteller bezogen.

PRISM-Setup-$shortVersion.exe installieren oder das gesamte PRISM-RGB-Windows.zip entpacken und PRISM-starten.cmd ausfuehren. Eine laufende alte PRISM-Version vorher schliessen. Microsoft Edge WebView2 wird fuer das native Fenster benoetigt.

Eine erkannte PC-Komponente ist nicht automatisch RGB-steuerbar. Lian Li hat in dieser Version keine eigenstaendige Anbindung; passive ARGB-Komponenten koennen nur ueber ihren Controller erscheinen.

Die Pakete wurden in GitHub Actions aus dem Quellcode erstellt. Die automatisierten Tests arbeiten mit simulierten Geraeten. Der Installer ist nicht digital signiert. SHA256SUMS.txt enthaelt die Pruefsummen beider Downloads.
"@
[IO.File]::WriteAllText((Join-Path $artifacts 'release-notes.md'), $releaseNotes, [Text.UTF8Encoding]::new($false))
if ($env:GITHUB_OUTPUT) { "version=$version" | Out-File -LiteralPath $env:GITHUB_OUTPUT -Append -Encoding utf8 }
Write-Host "Built PRISM ${version}: $installerName, PRISM-RGB-Windows.zip and SHA256SUMS.txt."
