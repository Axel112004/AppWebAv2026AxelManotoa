$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'Restaurar-Paquetes.ps1')
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (!(Test-Path -LiteralPath $vswhere)) { throw 'Se requiere Visual Studio con herramientas ASP.NET y .NET Framework 4.8.' }
$msbuild = & $vswhere -latest -products '*' -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe' | Select-Object -First 1
if (!$msbuild) { throw 'No se encontro MSBuild.' }
$webPath = Join-Path $PSScriptRoot 'WebAppPoliMusicV3'
& $msbuild (Join-Path $webPath 'WebAppPoliMusicV3.csproj') /t:Build /p:Configuration=Debug /v:minimal /nologo
if ($LASTEXITCODE -ne 0) { throw 'La compilacion fallo.' }
$listener = Get-NetTCPConnection -LocalPort 52130 -State Listen -ErrorAction SilentlyContinue
if (!$listener) {
    $iis = Join-Path $env:ProgramFiles 'IIS Express\iisexpress.exe'
    if (!(Test-Path -LiteralPath $iis)) { throw 'Se requiere IIS Express.' }
    Start-Process -FilePath $iis -ArgumentList "`"/path:$webPath`"", '/port:52130', '/systray:false' -WindowStyle Hidden
}
Start-Process 'http://localhost:52130/'
