#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_TEST_ROOT:?SMOKEY_TEST_ROOT is required}"
PROJECT_ROOT="$(cd "${SMOKEY_TEST_ROOT}/.." && pwd)"
: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR is required}"
STATE_FILE="${SMOKEY_STATE_DIR}/smoke-suite-dir"
BASE_DIR="$(cat "${STATE_FILE}")"

SOURCE_DIR="${SMOKEY_TEST_ROOT}/assets/continue-default"
TARGET_DIR="${BASE_DIR}/continue-after-failure"
rm -rf "${TARGET_DIR}"
cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

set +e
OUTPUT="$(${PROJECT_ROOT}/smokey --tests-dir "${TARGET_DIR}" 2>&1)"
STATUS=$?
set -e

printf '%s\n' "${OUTPUT}"

if [[ ${STATUS} -eq 0 ]]; then
  echo "[025-continue-after-failure] expected non-zero exit status" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"[continue-default] after failure still running"* ]]; then
  echo "[025-continue-after-failure] missing evidence that tests continued after failure" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"[continue-default] tail test"* ]]; then
  echo "[025-continue-after-failure] final test did not run" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"--- smokey summary ---"* ]]; then
  echo "[025-continue-after-failure] summary block missing" >&2
  exit 1
fi

LOG_FILE="${TARGET_DIR}/teardown.log"
if [[ ! -f "${LOG_FILE}" ]]; then
  echo "[025-continue-after-failure] teardown log missing" >&2
  exit 1
fi
COUNT=$(wc -l < "${LOG_FILE}")
if [[ ${COUNT} -ne 2 ]]; then
  echo "[025-continue-after-failure] expected teardown to run twice, got ${COUNT}" >&2
  cat "${LOG_FILE}" >&2 || true
  exit 1
fi
