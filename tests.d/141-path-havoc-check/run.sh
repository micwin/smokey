#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_STATE_DIR:?}"
BASE_PATH_FILE="${SMOKEY_STATE_DIR}/path-havoc-baseline"
FAKE_BIN_DIR="${SMOKEY_STATE_DIR}/fake-bin"

if [[ ! -f "${BASE_PATH_FILE}" ]]; then
  echo "[141-path-havoc-check] baseline file missing" >&2
  exit 1
fi

EXPECTED_PATH=$(<"${BASE_PATH_FILE}")
if [[ "${PATH}" != "${EXPECTED_PATH}" ]]; then
  echo "[141-path-havoc-check] PATH not restored" >&2
  exit 1
fi

if [[ -x "${FAKE_BIN_DIR}/bash" ]]; then
  echo "[141-path-havoc-check] fake bash still executable" >&2
  exit 1
fi

echo "[141-path-havoc-check] PATH restored"
