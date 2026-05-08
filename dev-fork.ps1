#!/usr/bin/env pwsh
# dev-fork.ps1 — setup + dev/build launcher para este fork.
# No upstream — vive solo en CarlosBarreto/voicebox (D-011).
#
# Uso:
#   pwsh ./dev-fork.ps1                  # bun install + bun run dev
#   pwsh ./dev-fork.ps1 -SkipInstall     # solo dev (asume node_modules ya existe)
#   pwsh ./dev-fork.ps1 -InstallOnly     # solo install
#   pwsh ./dev-fork.ps1 -Build           # bun install + just build (sidecar + Tauri)
#   pwsh ./dev-fork.ps1 -SkipInstall -Build   # solo build
#
# Pre-requisitos:
#   - bun (https://bun.sh)
#   - Python 3.12+ con `python` en PATH (sidecar venv).
#   - Para -Build: `just` (winget install casey.just / cargo install just) +
#     toolchain Rust + Visual Studio Build Tools (Windows) / Xcode CLI (Mac) /
#     paquetes WebKit GTK (Linux) — todo requerido por Tauri.

[CmdletBinding()]
param(
    [switch]$SkipInstall,
    [switch]$InstallOnly,
    [switch]$Build
)

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

Write-Host "voicebox fork — dev launcher" -ForegroundColor Cyan
$branch = git rev-parse --abbrev-ref HEAD 2>$null
if ($branch) { Write-Host "branch: $branch" -ForegroundColor DarkGray }

if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
    Write-Error "bun no está en PATH. Instala desde https://bun.sh y reabre la terminal."
}

if (-not $SkipInstall) {
    Write-Host "`nbun install" -ForegroundColor Yellow
    bun install
    if ($LASTEXITCODE -ne 0) { Write-Error "bun install falló (exit $LASTEXITCODE)" }
}

if ($InstallOnly) {
    Write-Host "`nInstall completo. Para arrancar dev: pwsh ./dev-fork.ps1 -SkipInstall" -ForegroundColor Green
    exit 0
}

if ($Build) {
    if (-not (Get-Command just -ErrorAction SilentlyContinue)) {
        Write-Error "just no está en PATH. Instala con: winget install casey.just (o 'cargo install just')"
    }
    Write-Host "`njust build (sidecar Python + app Tauri)" -ForegroundColor Yellow
    just build
    if ($LASTEXITCODE -ne 0) { Write-Error "just build falló (exit $LASTEXITCODE)" }
    Write-Host "`nBuild OK. Bundle Tauri en: tauri/src-tauri/target/release/bundle/" -ForegroundColor Green
    exit 0
}

Write-Host "`nbun run dev (Tauri + sidecar Python en :17493)" -ForegroundColor Yellow
bun run dev
