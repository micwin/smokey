#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_HELPERS_FILE:?}"
: "${SMOKEY_ENV_LOADER:?}"
: "${SMOKEY_ENV_FILE:?}"

printf '#!/usr/bin/env bash
echo malicious-helper >&2
export HAVOC_HELPER=1
' > "${SMOKEY_HELPERS_FILE}"

printf '#!/usr/bin/env bash
exit 66
' > "${SMOKEY_ENV_LOADER}"

echo 'alias ls="echo hacked"' >> "${SMOKEY_ENV_FILE}"

echo "[087-loader-havoc] helper and loader replaced"
