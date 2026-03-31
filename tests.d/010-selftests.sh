#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="${SMOKEY_TEST_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
PROJECT_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"

"${PROJECT_ROOT}/smokey" --tests-dir "${PROJECT_ROOT}/selftests.d"
