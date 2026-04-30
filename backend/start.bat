@echo off
REM Real Church Manager - PocketBase launcher (Windows)
setlocal enabledelayedexpansion

set DIR=%~dp0
cd /d "%DIR%"

set PB_BIN=%DIR%pocketbase.exe
set PB_VERSION=0.22.21

if not exist "%PB_BIN%" (
  echo Tai PocketBase v%PB_VERSION%...
  set ARCH=amd64
  set URL=https://github.com/pocketbase/pocketbase/releases/download/v%PB_VERSION%/pocketbase_%PB_VERSION%_windows_!ARCH!.zip
  echo   !URL!
  curl -fsSL "!URL!" -o "%TEMP%\pb.zip"
  powershell -Command "Expand-Archive -Path '%TEMP%\pb.zip' -DestinationPath '%TEMP%\pb_extracted' -Force"
  move /Y "%TEMP%\pb_extracted\pocketbase.exe" "%PB_BIN%" >nul
  rmdir /S /Q "%TEMP%\pb_extracted"
  del /Q "%TEMP%\pb.zip"
  echo OK: %PB_BIN%
)

set ADDR=127.0.0.1:8090
echo Chay PocketBase tren http://%ADDR%
echo   Admin UI: http://%ADDR%/_/
echo   Stop: Ctrl+C
echo.
"%PB_BIN%" serve --http=%ADDR% --dir="%DIR%pb_data" --hooksDir="%DIR%pb_hooks" --migrationsDir="%DIR%pb_migrations"
