#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="${SMOKEY_TEST_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
if [[ "$(basename "${TEST_ROOT}")" != "tests.d" ]]; then
  TEST_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
fi
PROJECT_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
: "${SMOKEY_STATE_DIR:?}"
STATE_FILE="${SMOKEY_STATE_DIR}/selftest-dir"
TMP_DIR="$(cat "${STATE_FILE}")"

SUITE_DIR="${TMP_DIR}/basic-suite"
mkdir -p "${SUITE_DIR}"

cat > "${SUITE_DIR}/010-pass.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "[basic] pass"
EOF
chmod +x "${SUITE_DIR}/010-pass.sh"

if ! "${PROJECT_ROOT}/smokey.sh" --tests-dir "${SUITE_DIR}"; then
  echo "[010-basic] smokey run failed" >&2
  exit 1
fi
