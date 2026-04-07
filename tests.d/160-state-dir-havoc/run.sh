#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_ENV_FILE:?}"
: "${SMOKEY_ENV_BEFORE_FILE:?}"

echo "[160-state-dir-havoc] removing env files"
rm -f "${SMOKEY_ENV_FILE}" "${SMOKEY_ENV_BEFORE_FILE}"
