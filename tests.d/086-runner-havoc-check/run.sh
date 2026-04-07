#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR is required}"
: "${SMOKEY_TEST_ROOT:?SMOKEY_TEST_ROOT is required}"

BASE_PATH_FILE="${SMOKEY_STATE_DIR}/havoc-path-baseline"
BASE_ROOT_FILE="${SMOKEY_STATE_DIR}/havoc-root-baseline"

if [[ ! -f "${BASE_PATH_FILE}" || ! -f "${BASE_ROOT_FILE}" ]]; then
  echo "[086-runner-havoc-check] baseline files missing" >&2
  exit 1
fi

EXPECTED_PATH=$(<"${BASE_PATH_FILE}")
EXPECTED_ROOT=$(<"${BASE_ROOT_FILE}")

if [[ "${PATH}" != "${EXPECTED_PATH}" ]]; then
  echo "[086-runner-havoc-check] PATH was not restored" >&2
  exit 1
fi

if [[ "${SMOKEY_TEST_ROOT}" != "${EXPECTED_ROOT}" ]]; then
  echo "[086-runner-havoc-check] SMOKEY_TEST_ROOT mismatch" >&2
  exit 1
fi

if [[ -n "${HAVOC_GREMLIN+x}" ]]; then
  echo "[086-runner-havoc-check] HAVOC_GREMLIN leaked into next test" >&2
  exit 1
fi

if alias ls 2>/dev/null | grep -q 'havoc-ls'; then
  echo "[086-runner-havoc-check] alias persisted" >&2
  exit 1
fi

case "${SMOKEY_ENV_FILE}" in
  "${SMOKEY_STATE_DIR}"/*) ;; 
  *) echo "[086-runner-havoc-check] SMOKEY_ENV_FILE not reset" >&2; exit 1 ;;
esac

if [[ -f "${SMOKEY_STATE_DIR}/havoc-marker" ]]; then
  echo "[086-runner-havoc-check] state marker should persist (expected)" >/dev/null
else
  echo "[086-runner-havoc-check] unable to find havoc marker" >&2
  exit 1
fi

echo "[086-runner-havoc-check] environment restored"
