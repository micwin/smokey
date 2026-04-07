#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_STATE_DIR:?}"
ZOMBIE_PID_FILE="${SMOKEY_STATE_DIR}/zombie.pid"

if [[ ! -f "${ZOMBIE_PID_FILE}" ]]; then
  echo "[151-zombie-havoc-check] missing PID file" >&2
  exit 1
fi
ZPID=$(<"${ZOMBIE_PID_FILE}")
if kill -0 "${ZPID}" 2>/dev/null; then
  echo "[151-zombie-havoc-check] zombie process ${ZPID} still alive" >&2
  exit 1
fi

echo "[151-zombie-havoc-check] no leftover background jobs"
