@echo off
REM ============================================================================
REM  PoliMusic | Script de publicacion en IIS
REM ----------------------------------------------------------------------------
REM  Copia el proyecto a la carpeta que sirve IIS y elimina los archivos
REM  obsoletos de versiones anteriores.
REM
REM  Ejecutar con clic derecho -> "Ejecutar como administrador".
REM ============================================================================
setlocal

REM --- Carpeta que sirve IIS (ajustar si usa otra) ---------------------------
set "DESTINO=C:\inetpub\wwwroot\webapppolimusicv1_asp"
set "ORIGEN=%~dp0"

echo.
echo  ============================================
echo   PoliMusic - Publicacion en IIS
echo  ============================================
echo   Origen : %ORIGEN%
echo   Destino: %DESTINO%
echo.

REM --- Comprobar permisos de administrador ----------------------------------
net session >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] Este script necesita permisos de administrador.
    echo          Cierre esta ventana y ejecutelo con
    echo          clic derecho -^> "Ejecutar como administrador".
    echo.
    pause
    exit /b 1
)

if not exist "%DESTINO%" mkdir "%DESTINO%"

REM --- Eliminar la carpeta admin\ de versiones anteriores --------------------
if exist "%DESTINO%\admin" (
    echo  Eliminando la carpeta obsoleta "admin\"...
    rmdir /s /q "%DESTINO%\admin"
)

REM --- Copiar el proyecto ----------------------------------------------------
echo  Copiando archivos...
xcopy "%ORIGEN%*.asp"       "%DESTINO%\" /Y /Q >nul
xcopy "%ORIGEN%web.config"  "%DESTINO%\" /Y /Q >nul
xcopy "%ORIGEN%README.md"   "%DESTINO%\" /Y /Q >nul
xcopy "%ORIGEN%BDD_PoliMusic.sql" "%DESTINO%\" /Y /Q >nul
xcopy "%ORIGEN%assets"      "%DESTINO%\assets\"      /E /I /Y /Q >nul
xcopy "%ORIGEN%includes"    "%DESTINO%\includes\"    /E /I /Y /Q >nul
xcopy "%ORIGEN%database"    "%DESTINO%\database\"    /E /I /Y /Q >nul
xcopy "%ORIGEN%songFiles"   "%DESTINO%\songFiles\"   /E /I /Y /Q >nul
xcopy "%ORIGEN%userImages"  "%DESTINO%\userImages\"  /E /I /Y /Q >nul
xcopy "%ORIGEN%playlistImages" "%DESTINO%\playlistImages\" /E /I /Y /Q >nul
xcopy "%ORIGEN%albumImages"    "%DESTINO%\albumImages\"    /E /I /Y /Q >nul
xcopy "%ORIGEN%artistImages"   "%DESTINO%\artistImages\"   /E /I /Y /Q >nul
xcopy "%ORIGEN%capturas"       "%DESTINO%\capturas\"       /E /I /Y /Q >nul

REM --- Permiso de lectura para la identidad de IIS --------------------------
echo  Otorgando permiso de lectura a IIS...
icacls "%DESTINO%" /grant "IIS_IUSRS:(OI)(CI)(RX)" /T /Q >nul

echo.
echo  ============================================
echo   Publicacion completada
echo  ============================================
echo   Abra en el navegador:
echo     http://localhost/webapppolimusicv1_asp/
echo.
echo   Comprobacion de la instalacion:
echo     http://localhost/webapppolimusicv1_asp/diagnostico.asp
echo.
pause
endlocal
