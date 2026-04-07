#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_HELPERS_FILE:?}"
: "${SMOKEY_ENV_LOADER:?}"
: "${SMOKEY_ENV_FILE:?}"

if [[ ! -s "${SMOKEY_HELPERS_FILE}" ]]; then
  echo "[086-loader-havoc-check] helpers file missing" >&2
  exit 1
fi

grep -q 'malicious-helper' "${SMOKEY_HELPERS_FILE}" && {
  echo "[086-loader-havoc-check] helpers file was not restored" >&2
  exit 1
}

if [[ ! -s "${SMOKEY_ENV_LOADER}" ]]; then
  echo "[086-loader-havoc-check] loader missing" >&2
  exit 1
fi

grep -q 'exit 66' "${SMOKEY_ENV_LOADER}" && {
  echo "[086-loader-havoc-check] loader still contains injected exit" >&2
  exit 1
}

if alias ls 2>/dev/null | grep -q 'hacked'; then
  echo "[086-loader-havoc-check] alias persisted" >&2
  exit 1
fi

echo "[086-loader-havoc-check] helper/loader intact"
