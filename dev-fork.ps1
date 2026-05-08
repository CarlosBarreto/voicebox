#!/usr/bin/env pwsh
# dev-fork.ps1 — setup + dev launcher para este fork.
# No upstream — vive solo en CarlosBarreto/voicebox (D-011).
#
# Uso:
#   pwsh ./dev-fork.ps1            # bun install + bun run dev
#   pwsh ./dev-fork.ps1 -SkipInstall   # solo dev (asume node_modules ya existe)
#   pwsh ./dev-fork.ps1 -InstallOnly   # solo install
#
# Pre-requisitos: bun (https://bun.sh), Python 3.12+ con `python` en PATH
# (bun run dev → setup:dev arranca el venv del sidecar Python).

[CmdletBinding()]
param(
    [switch]$SkipInstall,
    [switch]$InstallOnly
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

Write-Host "`nbun run dev (Tauri + sidecar Python en :17493)" -ForegroundColor Yellow
bun run dev
