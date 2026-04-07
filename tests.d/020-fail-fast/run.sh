#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="${SMOKEY_TEST_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
case "$(basename "${TEST_ROOT}")" in
  tests.d) ;;
  *) TEST_ROOT="$(cd "${TEST_ROOT}/.." && pwd)" ;;
esac
PROJECT_ROOT="$(cd "${TEST_ROOT}/.." && pwd)"
: "${SMOKEY_STATE_DIR:?}"
STATE_FILE="${SMOKEY_STATE_DIR}/smoke-suite-dir"
TMP_DIR="$(cat "${STATE_FILE}")"

SUITE_DIR="${TMP_DIR}/fail-fast"
mkdir -p "${SUITE_DIR}"

cat > "${SUITE_DIR}/010-pass.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "[fail-fast] first pass"
EOF

cat > "${SUITE_DIR}/020-fail.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "[fail-fast] intentional failure" >&2
exit 1
EOF

cat > "${SUITE_DIR}/030-should-skip.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "should not run" >&2
exit 2
EOF

chmod +x "${SUITE_DIR}/"*".sh"

if "${PROJECT_ROOT}/smokey" --tests-dir "${SUITE_DIR}" --fail-fast; then
  echo "[020-fail-fast] expected failure but smokey exited 0" >&2
  exit 1
fi
