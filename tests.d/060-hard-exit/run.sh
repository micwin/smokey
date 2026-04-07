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

SUITE_DIR="${TMP_DIR}/hard-exit"
mkdir -p "${SUITE_DIR}"
SENTINEL="${SUITE_DIR}/parent-continued"

cat > "${SUITE_DIR}/010-hard-exit.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "[hard-exit] invoking exit 77"
exit 77
EOF
chmod +x "${SUITE_DIR}/010-hard-exit.sh"

if "${PROJECT_ROOT}/smokey" --tests-dir "${SUITE_DIR}"; then
  echo "[060-hard-exit] smokey unexpectedly succeeded" >&2
  exit 1
fi

echo "parent survived failure" > "${SENTINEL}"

if [[ ! -f "${SENTINEL}" ]]; then
  echo "[060-hard-exit] sentinel missing, parent likely aborted" >&2
  exit 1
fi
