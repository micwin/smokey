#!/usr/bin/env bash
set -euo pipefail
echo "[fail-fast-preserve] writing artifact"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "payload" > "${SCRIPT_DIR}/artifact.txt"
