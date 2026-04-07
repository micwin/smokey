#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ARTIFACT_PATH="${SUITE_DIR}/artifact.txt"
rm -f "${ARTIFACT_PATH}"
LOG_FILE="${SUITE_DIR}/teardown.log"
if [[ -f "${LOG_FILE}" ]]; then
  echo "final" >> "${LOG_FILE}"
else
  echo "initial" > "${LOG_FILE}"
fi
