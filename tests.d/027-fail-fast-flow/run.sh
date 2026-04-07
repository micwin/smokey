#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_TEST_ROOT:?}"
PROJECT_ROOT="$(cd "${SMOKEY_TEST_ROOT}/.." && pwd)"
: "${SMOKEY_STATE_DIR:?}"
STATE_FILE="${SMOKEY_STATE_DIR}/smoke-suite-dir"
BASE_DIR="$(cat "${STATE_FILE}")"

SOURCE_DIR="${SMOKEY_TEST_ROOT}/assets/fail-fast-flow"
TARGET_DIR="${BASE_DIR}/fail-fast-flow"
rm -rf "${TARGET_DIR}"
cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

set +e
OUTPUT="$(${PROJECT_ROOT}/smokey --tests-dir "${TARGET_DIR}" --fail-fast 2>&1)"
STATUS=$?
set -e

printf '%s\n' "${OUTPUT}"

if [[ ${STATUS} -eq 0 ]]; then
  echo "[027-fail-fast-flow] expected non-zero exit" >&2
  exit 1
fi

if [[ "${OUTPUT}" == *"[fail-fast-suite] should have been skipped"* ]]; then
  echo "[027-fail-fast-flow] fail-fast did not stop remaining tests" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"--- smokey summary ---"* ]]; then
  echo "[027-fail-fast-flow] summary missing" >&2
  exit 1
fi

LOG_FILE="${TARGET_DIR}/teardown.log"
if [[ ! -f "${LOG_FILE}" ]]; then
  echo "[027-fail-fast-flow] teardown log missing" >&2
  exit 1
fi
COUNT=$(wc -l < "${LOG_FILE}")
if [[ ${COUNT} -ne 2 ]]; then
  echo "[027-fail-fast-flow] fail-fast should still run final teardown" >&2
  cat "${LOG_FILE}" >&2 || true
  exit 1
fi
