#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_HELPERS_FILE:?}"
: "${SMOKEY_ENV_LOADER:?}"
: "${SMOKEY_ENV_FILE:?}"

if grep -q 'malicious-helper' "${SMOKEY_HELPERS_FILE}"; then
  echo "[088-loader-havoc-check] helper remained tampered" >&2
  exit 1
fi

grep -q 'exit 66' "${SMOKEY_ENV_LOADER}" && {
  echo "[088-loader-havoc-check] loader still replaced" >&2
  exit 1
}

echo "[088-loader-havoc-check] loader survived"
