#!/usr/bin/env bash
# dev-fork.sh — setup + dev launcher para este fork.
# No upstream — vive solo en CarlosBarreto/voicebox (D-011).
#
# Uso:
#   ./dev-fork.sh                # bun install + bun run dev
#   ./dev-fork.sh --skip-install # solo dev (asume node_modules ya existe)
#   ./dev-fork.sh --install-only # solo install
#
# Pre-requisitos: bun (https://bun.sh), Python 3.12+ con `python3` en PATH.

set -euo pipefail

cd "$(dirname "$0")"

skip_install=0
install_only=0
for arg in "$@"; do
    case "$arg" in
        --skip-install) skip_install=1 ;;
        --install-only) install_only=1 ;;
        -h|--help)
            sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "Flag desconocida: $arg" >&2; exit 2 ;;
    esac
done

echo "voicebox fork — dev launcher"
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
[ -n "$branch" ] && echo "branch: $branch"

if ! command -v bun >/dev/null 2>&1; then
    echo "bun no está en PATH. Instala desde https://bun.sh y reabre la terminal." >&2
    exit 1
fi

if [ "$skip_install" -eq 0 ]; then
    echo
    echo "bun install"
    bun install
fi

if [ "$install_only" -eq 1 ]; then
    echo
    echo "Install completo. Para arrancar dev: ./dev-fork.sh --skip-install"
    exit 0
fi

echo
echo "bun run dev (Tauri + sidecar Python en :17493)"
bun run dev
