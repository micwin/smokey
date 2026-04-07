#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="${SMOKEY_TEST_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
case "$(basename "${TEST_ROOT}")" in
  tests.d) ;;
  *) TEST_ROOT="$(cd "${TEST_ROOT}/.." && pwd)" ;;
esac
