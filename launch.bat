@echo off
setlocal EnableExtensions
cd /d "%~dp0"
chcp 65001 >nul

REM Open Design - Windows launcher (repo root)
REM Usage: launch.bat [command]
REM   (no arg)  = web   foreground daemon + web

set "ACTION=%~1"
if "%ACTION%"=="" set "ACTION=web"

if /i "%ACTION%"=="help" goto :help
if /i "%ACTION%"=="?" goto :help
if /i "%ACTION%"=="install" goto :install
if /i "%ACTION%"=="web" goto :web
if /i "%ACTION%"=="run" goto :web
if /i "%ACTION%"=="start" goto :start
if /i "%ACTION%"=="desktop" goto :desktop
if /i "%ACTION%"=="stop" goto :stop
if /i "%ACTION%"=="status" goto :status
if /i "%ACTION%"=="logs" goto :logs
if /i "%ACTION%"=="check" goto :check
if /i "%ACTION%"=="restart" goto :restart

echo [launch.bat] Unknown command: %ACTION%
echo.
goto :help

:ensure_pnpm
where pnpm >nul 2>&1
if not errorlevel 1 exit /b 0
echo [info] pnpm not on PATH; trying corepack (no enable)...
call corepack pnpm -v >nul 2>&1
if not errorlevel 1 exit /b 0
echo [info] Installing pnpm@10.33.2 globally via npm...
echo [info] If corepack failed with EPERM on Program Files, this path is expected.
call npm install -g pnpm@10.33.2
if errorlevel 1 (
  echo [error] Could not install pnpm. Try in an elevated shell:
  echo         npm install -g pnpm@10.33.2
  echo         Or run once as Admin: corepack enable
  exit /b 1
)
where pnpm >nul 2>&1
if errorlevel 1 (
  echo [error] pnpm still not on PATH. Close this window, open a new terminal, retry.
  exit /b 1
)
exit /b 0

:precheck
where node >nul 2>&1
if errorlevel 1 (
  echo [error] Node.js not found. Install Node 24.x and retry.
  exit /b 1
)
call :ensure_pnpm
exit /b %ERRORLEVEL%

:install
call :precheck
if errorlevel 1 exit /b 1
echo [install] pnpm install
call pnpm install
if errorlevel 1 exit /b 1
echo.
echo [install] If native builds were blocked, run: pnpm approve-builds
echo [install] Then: launch.bat web
exit /b 0

:web
call :precheck
if errorlevel 1 exit /b 1
echo [web] Starting daemon + web (foreground). Ctrl+C to stop.
echo [web] Open the URL printed below in your browser.
echo.
call pnpm tools-dev run web
exit /b %ERRORLEVEL%

:start
call :precheck
if errorlevel 1 exit /b 1
if "%~2"=="" (
  echo [start] Starting daemon + web in background...
  call pnpm tools-dev start web
) else (
  echo [start] Starting %~2 ...
  call pnpm tools-dev start %~2
)
exit /b %ERRORLEVEL%

:desktop
call :precheck
if errorlevel 1 exit /b 1
echo [desktop] Starting daemon + web + desktop in background...
call pnpm tools-dev
exit /b %ERRORLEVEL%

:stop
call :precheck
if errorlevel 1 exit /b 1
if "%~2"=="" (
  call pnpm tools-dev stop
) else (
  call pnpm tools-dev stop %~2
)
exit /b %ERRORLEVEL%

:status
call :precheck
if errorlevel 1 exit /b 1
call pnpm tools-dev status
exit /b %ERRORLEVEL%

:logs
call :precheck
if errorlevel 1 exit /b 1
call pnpm tools-dev logs
exit /b %ERRORLEVEL%

:check
call :precheck
if errorlevel 1 exit /b 1
call pnpm tools-dev check
exit /b %ERRORLEVEL%

:restart
call :precheck
if errorlevel 1 exit /b 1
call pnpm tools-dev restart
exit /b %ERRORLEVEL%

:help
echo Open Design launcher
echo.
echo   launch.bat              Same as: launch.bat web
echo   launch.bat install      First-time: pnpm install
echo   launch.bat web          Foreground daemon + web (dev default)
echo   launch.bat start        Background daemon + web
echo   launch.bat start web    Background web only (daemon + web)
echo   launch.bat desktop      Background daemon + web + Electron
echo   launch.bat stop         Stop managed runtimes
echo   launch.bat status       Show runtime status
echo   launch.bat logs         Tail recent logs
echo   launch.bat check        Status + diagnostics
echo   launch.bat restart      Restart managed runtimes
echo   launch.bat help         This help
echo.
echo Prerequisites: Node ~24, pnpm 10.33.x
echo EPERM on corepack enable: npm install -g pnpm@10.33.2
echo Docs: QUICKSTART.md, docs\windows-troubleshooting.md
exit /b 0
