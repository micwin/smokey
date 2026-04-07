#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_STATE_DIR:?}"
BASE_PATH_FILE="${SMOKEY_STATE_DIR}/path-havoc-baseline"
FAKE_BIN_DIR="${SMOKEY_STATE_DIR}/fake-bin"

printf '%s' "${PATH}" > "${BASE_PATH_FILE}"
rm -rf "${FAKE_BIN_DIR}"
mkdir -p "${FAKE_BIN_DIR}"
cat > "${FAKE_BIN_DIR}/bash" <<'SCRIPT'
#!/usr/bin/env bash
echo "[140-path-havoc] intercepted bash" >&2
exit 99
SCRIPT
chmod +x "${FAKE_BIN_DIR}/bash"

export PATH="${FAKE_BIN_DIR}:${PATH}"

cat > "${SMOKEY_STATE_DIR}/path-havoc-note" <<'NOTE'
This file proves the fake PATH entry was inserted.
NOTE

echo "[140-path-havoc] PATH poisoned with fake bash"
