#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_ENV_FILE:?}"

smokey_env_save SMOKEY_STATE_DIR
smokey_env_show | grep -q '^export SMOKEY_STATE_DIR='

echo "[161-state-dir-havoc-check] env file regenerated"
