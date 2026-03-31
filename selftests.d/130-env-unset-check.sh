#!/usr/bin/env bash
set -euo pipefail

if [[ ${SMOKEY_SHARED_TOKEN+x} ]]; then
  echo "[130-env-unset-check] shared env should be unset" >&2
  exit 1
fi
