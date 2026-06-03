#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "${SMOKEY_TEST_ROOT}/.." && pwd)"

# Capture the bundled agent help from the repo-local Smokey executable.
OUTPUT="$("${PROJECT_ROOT}/smokey" agents-help)"

# Verify that the help is agent-focused and includes the core suite rule.
if [[ "${OUTPUT}" != *"# Smokey Agent Help"* ]]; then
  echo "[015-agents-help] missing title" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"Do not run individual test scripts directly"* ]]; then
  echo "[015-agents-help] missing direct-test warning" >&2
  exit 1
fi

# Verify that the help documents temporary skip edges for suite-local debugging.
if [[ "${OUTPUT}" != *'exit "${SMOKEY_SKIP_CODE}"'* ]]; then
  echo "[015-agents-help] missing temporary skip guidance" >&2
  exit 1
fi
