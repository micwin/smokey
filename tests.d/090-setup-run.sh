#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="${SMOKEY_TEST_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)}"
if [[ "$(basename "${TEST_ROOT}")" != "tests.d" ]]; then
  TEST_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
fi
PROJECT_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"

: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR is required}"
SUITE_DIR="${SMOKEY_STATE_DIR}/setup-order"
MARKER_FILE="${SUITE_DIR}/.setup-flag"

mkdir -p "${SUITE_DIR}/000-setup" "${SUITE_DIR}/999-teardown"

cat > "${SUITE_DIR}/000-setup/run.sh" <<'SETUP'
#!/usr/bin/env bash
set -euo pipefail
SUITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
MARKER_FILE="${SUITE_DIR}/.setup-flag"
echo "setup-ran" > "${MARKER_FILE}"
SETUP

cat > "${SUITE_DIR}/010-verify.sh" <<'VERIFY'
#!/usr/bin/env bash
set -euo pipefail
SUITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
MARKER_FILE="${SUITE_DIR}/.setup-flag"
if [[ ! -f "${MARKER_FILE}" ]]; then
  echo "[nested] setup marker missing" >&2
  exit 1
fi
VERIFY

cat > "${SUITE_DIR}/999-teardown/run.sh" <<'CLEAN'
#!/usr/bin/env bash
set -euo pipefail
SUITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
MARKER_FILE="${SUITE_DIR}/.setup-flag"
rm -f "${MARKER_FILE}"
CLEAN

chmod +x "${SUITE_DIR}/000-setup/run.sh" "${SUITE_DIR}/010-verify.sh" "${SUITE_DIR}/999-teardown/run.sh"

if ! "${PROJECT_ROOT}/smokey" --tests-dir "${SUITE_DIR}"; then
  echo "[090-setup-run] nested smokey run failed" >&2
  exit 1
fi

echo "[090-setup-run] ok"
