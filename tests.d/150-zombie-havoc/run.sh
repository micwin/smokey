#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_STATE_DIR:?}"
ZOMBIE_PID_FILE="${SMOKEY_STATE_DIR}/zombie.pid"

(sleep 9999) &
ZPID=$!
echo ${ZPID} > "${ZOMBIE_PID_FILE}"

echo "[150-zombie-havoc] spawned background sleep ${ZPID}"
