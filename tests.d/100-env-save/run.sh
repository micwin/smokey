#!/usr/bin/env bash
set -euo pipefail

export SMOKEY_SHARED_TOKEN="from-shared-env"
smokey_env_save SMOKEY_SHARED_TOKEN
smokey_env_show | grep -q '^export SMOKEY_SHARED_TOKEN='
