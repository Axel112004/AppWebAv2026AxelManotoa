$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$packageRoot = Join-Path $repoRoot 'packages'
$templatePackages = 'C:\Program Files (x86)\Microsoft Visual Studio\Shared\Packages'
[xml]$packageConfig = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'WebAppPoliMusicV3\packages.config')
New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null
foreach ($package in $packageConfig.packages.package) {
    $id = [string]$package.id
    $version = [string]$package.version
    $folder = "$id.$version"
    $destination = Join-Path $packageRoot $folder
    if (Test-Path -LiteralPath $destination) { continue }
    $localPackage = Join-Path $templatePackages $folder
    if (Test-Path -LiteralPath $localPackage) {
        Copy-Item -LiteralPath $localPackage -Destination $destination -Recurse
    } else {
        $packageUri = "https://api.nuget.org/v3-flatcontainer/$($id.ToLowerInvariant())/$version/$($id.ToLowerInvariant()).$version.nupkg"
        $archive = Join-Path ([IO.Path]::GetTempPath()) ("polimusic-" + [Guid]::NewGuid().ToString('N') + '.zip')
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $packageUri -OutFile $archive -UseBasicParsing
            Expand-Archive -LiteralPath $archive -DestinationPath $destination
        } finally {
            if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive }
        }
    }
    Write-Host "Restaurado: $folder"
}
Write-Host 'Paquetes de PoliMusic V3 disponibles.'
