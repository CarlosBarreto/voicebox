@echo off
REM dev-fork.bat — setup + dev/build launcher para este fork (cmd.exe).
REM No upstream — vive solo en CarlosBarreto/voicebox (D-011).
REM
REM Uso:
REM   dev-fork.bat                       Bun install + bun run dev
REM   dev-fork.bat --skip-install        Solo dev (asume node_modules existe)
REM   dev-fork.bat --install-only        Solo install
REM   dev-fork.bat --build               Bun install + just build
REM   dev-fork.bat --skip-install --build  Solo build
REM
REM Pre-requisitos:
REM   - bun (https://bun.sh)
REM   - Python 3.12+ con `python` en PATH (sidecar venv)
REM   - Para --build: `just` (winget install casey.just) + Rust toolchain +
REM     Visual Studio Build Tools con C++ workload (Tauri).

setlocal enabledelayedexpansion

set "skip_install=0"
set "install_only=0"
set "do_build=0"

:parse_args
if "%~1"=="" goto :args_done
if /i "%~1"=="--skip-install" ( set "skip_install=1" & shift & goto :parse_args )
if /i "%~1"=="--install-only" ( set "install_only=1" & shift & goto :parse_args )
if /i "%~1"=="--build"        ( set "do_build=1"     & shift & goto :parse_args )
if /i "%~1"=="-h"             goto :show_help
if /i "%~1"=="--help"         goto :show_help
echo Flag desconocida: %~1 1>&2
exit /b 2

:show_help
for /f "tokens=1,* delims=:" %%a in ('findstr /n "^REM" "%~f0"') do echo.%%b
exit /b 0

:args_done
cd /d "%~dp0"

echo voicebox fork - dev launcher
for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD 2^>nul') do echo branch: %%b

where bun >nul 2>nul
if errorlevel 1 (
    echo bun no esta en PATH. Instala desde https://bun.sh y reabre la terminal. 1>&2
    exit /b 1
)

if "%skip_install%"=="0" (
    echo.
    echo bun install
    call bun install
    if errorlevel 1 exit /b !errorlevel!
)

if "%install_only%"=="1" (
    echo.
    echo Install completo. Para arrancar dev: dev-fork.bat --skip-install
    exit /b 0
)

if "%do_build%"=="1" (
    where just >nul 2>nul
    if errorlevel 1 (
        echo just no esta en PATH. Instala con: winget install casey.just  ^(o cargo install just^) 1>&2
        exit /b 1
    )
    echo.
    echo just build ^(sidecar Python + app Tauri^)
    call just build
    if errorlevel 1 exit /b !errorlevel!
    echo.
    echo Build OK. Bundle Tauri en: tauri\src-tauri\target\release\bundle\
    exit /b 0
)

echo.
echo bun run dev ^(Tauri + sidecar Python en :17493^)
call bun run dev
