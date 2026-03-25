#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="${SMOKEY_TEST_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
if [[ "$(basename "${TEST_ROOT}")" != "tests.d" ]]; then
  TEST_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
fi
PROJECT_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR is required}"
STATE_FILE="${SMOKEY_STATE_DIR}/selftest-dir"

TMP_DIR="$(mktemp -d)"
echo "${TMP_DIR}" > "${STATE_FILE}"
echo "[smokey selftests] tmp dir: ${TMP_DIR}"
