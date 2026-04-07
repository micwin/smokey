#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="${SMOKEY_TEST_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
case "$(basename "${TEST_ROOT}")" in
  tests.d) ;;
  *) TEST_ROOT="$(cd "${TEST_ROOT}/.." && pwd)" ;;
esac
PROJECT_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR is required}"
STATE_FILE="${SMOKEY_STATE_DIR}/smoke-suite-dir"

TMP_DIR="$(mktemp -d)"
echo "${TMP_DIR}" > "${STATE_FILE}"
echo "[smokey tests] tmp dir: ${TMP_DIR}"
