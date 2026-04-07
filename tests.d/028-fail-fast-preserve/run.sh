#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_TEST_ROOT:?}"
PROJECT_ROOT="$(cd "${SMOKEY_TEST_ROOT}/.." && pwd)"
: "${SMOKEY_STATE_DIR:?}"
STATE_FILE="${SMOKEY_STATE_DIR}/smoke-suite-dir"
BASE_DIR="$(cat "${STATE_FILE}")"

SOURCE_DIR="${SMOKEY_TEST_ROOT}/assets/fail-fast-preserve"
TARGET_DIR="${BASE_DIR}/fail-fast-preserve"
rm -rf "${TARGET_DIR}"
cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

set +e
OUTPUT="$(${PROJECT_ROOT}/smokey --tests-dir "${TARGET_DIR}" --fail-fast --preserve 2>&1)"
STATUS=$?
set -e

printf '%s\n' "${OUTPUT}"

if [[ ${STATUS} -eq 0 ]]; then
  echo "[028-fail-fast-preserve] expected non-zero exit" >&2
  exit 1
fi

if [[ "${OUTPUT}" == *"[fail-fast-preserve] should skip"* ]]; then
  echo "[028-fail-fast-preserve] fail-fast did not skip remaining tests" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"--- smokey summary ---"* ]]; then
  echo "[028-fail-fast-preserve] summary missing" >&2
  exit 1
fi

if [[ ! -f "${TARGET_DIR}/artifact.txt" ]]; then
  echo "[028-fail-fast-preserve] artifact should remain when --preserve is set" >&2
  exit 1
fi

LOG_FILE="${TARGET_DIR}/teardown.log"
if [[ ! -f "${LOG_FILE}" ]]; then
  echo "[028-fail-fast-preserve] teardown log missing" >&2
  exit 1
fi
LINES=$(wc -l < "${LOG_FILE}")
if [[ ${LINES} -ne 1 ]]; then
  echo "[028-fail-fast-preserve] teardown should run only once with --preserve" >&2
  cat "${LOG_FILE}" >&2 || true
  exit 1
fi
