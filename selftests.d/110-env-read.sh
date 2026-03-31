#!/usr/bin/env bash
set -euo pipefail

if [[ "${SMOKEY_SHARED_TOKEN:-}" != "from-shared-env" ]]; then
  echo "[110-env-read] shared env missing or wrong: ${SMOKEY_SHARED_TOKEN:-<unset>}" >&2
  exit 1
fi
