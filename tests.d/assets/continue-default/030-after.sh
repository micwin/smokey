#!/usr/bin/env bash
set -euo pipefail
echo "[continue-default] after failure still running"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
touch "${SCRIPT_DIR}/after-marker"
