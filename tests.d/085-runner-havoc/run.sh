#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR is required}"

BASE_PATH_FILE="${SMOKEY_STATE_DIR}/havoc-path-baseline"
BASE_ROOT_FILE="${SMOKEY_STATE_DIR}/havoc-root-baseline"

printf '%s' "${PATH}" > "${BASE_PATH_FILE}"
printf '%s' "${SMOKEY_TEST_ROOT}" > "${BASE_ROOT_FILE}"

export PATH="/tmp/smokey-havoc-${RANDOM}"
export HAVOC_GREMLIN="true"
unset SMOKEY_TEST_ROOT
export SMOKEY_ENV_FILE="/tmp/havoc-env"
export SMOKEY_HELPERS_FILE="/tmp/havoc-helpers"
export BASH_ENV="/tmp/havoc-bash-env"

printf '%s' "corruption" > "${SMOKEY_STATE_DIR}/havoc-marker"

alias ls='echo havoc-ls'

printf '[085-runner-havoc] environment poisoned\n'
