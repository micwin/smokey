#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="${SMOKEY_TEST_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
if [[ "$(basename "${TEST_ROOT}")" != "tests.d" && "$(basename "${TEST_ROOT}")" != "selftests.d" ]]; then
  TEST_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
fi
: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR is required}"
STATE_FILE="${SMOKEY_STATE_DIR}/selftest-dir"
if [[ -f "${STATE_FILE}" ]]; then
  TMP_DIR="$(cat "${STATE_FILE}")"
  rm -rf "${TMP_DIR}"
  rm -f "${STATE_FILE}"
fi
