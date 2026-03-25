#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
TARGET_NAME="smokey"
BINARY_SOURCE="${SCRIPT_DIR}/smokey.sh"
if [[ ! -x "${BINARY_SOURCE}" ]]; then
  chmod +x "${BINARY_SOURCE}"
fi

if [[ $(id -u) -eq 0 ]]; then
  PREFIX="/usr/local/bin"
else
  if [[ -d "${HOME}/.local/bin" ]]; then
    PREFIX="${HOME}/.local/bin"
  else
    mkdir -p "${HOME}/.local/bin"
    PREFIX="${HOME}/.local/bin"
  fi
fi

mkdir -p "${PREFIX}"
INSTALL_PATH="${PREFIX}/${TARGET_NAME}"
cp "${BINARY_SOURCE}" "${INSTALL_PATH}"
chmod +x "${INSTALL_PATH}"
echo "Installed ${TARGET_NAME} to ${INSTALL_PATH}"

if [[ ${PREFIX} == "${HOME}/.local/bin" ]] && [[ ":${PATH}:" != *":${PREFIX}:"* ]]; then
  echo "WARNING: ${PREFIX} is not in your PATH. Add it to your shell profile to use ${TARGET_NAME} directly." >&2
fi
