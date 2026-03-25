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

SUITE_DIR="${TMP_DIR}/trap-failfast"
mkdir -p "${SUITE_DIR}"

SENTINEL="${SUITE_DIR}/should-not-exist"

cat > "${SUITE_DIR}/010-trap.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[trap-failfast] exit trap firing" >&2; exit 55' EXIT
echo "[trap-failfast] body executing"
EOF

cat > "${SUITE_DIR}/020-should-skip.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
echo "unexpected execution" >&2
touch "${SENTINEL}"
EOF

chmod +x "${SUITE_DIR}/010-trap.sh" "${SUITE_DIR}/020-should-skip.sh"

if "${PROJECT_ROOT}/smokey.sh" --tests-dir "${SUITE_DIR}" --fail-fast; then
  echo "[040-trap-failfast] smokey should have failed" >&2
  exit 1
fi

if [[ -e "${SENTINEL}" ]]; then
  echo "[040-trap-failfast] fail-fast did not stop execution" >&2
  exit 1
fi
