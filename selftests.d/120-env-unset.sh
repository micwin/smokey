#!/usr/bin/env bash
set -euo pipefail

smokey_env_unset SMOKEY_SHARED_TOKEN
smokey_env_show | grep -q '^unset SMOKEY_SHARED_TOKEN$'
