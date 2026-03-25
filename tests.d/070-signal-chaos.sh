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

SUITE_DIR="${TMP_DIR}/signal-chaos"
mkdir -p "${SUITE_DIR}"
SENTINEL="${SUITE_DIR}/signal-done"

cat > "${SUITE_DIR}/010-signal.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[signal-chaos] trapped INT"; exit 66' INT
echo "[signal-chaos] sending SIGTERM to self"
kill -s TERM "$$"
sleep 2
EOF
chmod +x "${SUITE_DIR}/010-signal.sh"

set +e
"${PROJECT_ROOT}/smokey.sh" --tests-dir "${SUITE_DIR}" >"${SUITE_DIR}/run.log" 2>&1
status=$?
set -e

if [[ ${status} -eq 0 ]]; then
  cat "${SUITE_DIR}/run.log" >&2
  echo "[070-signal-chaos] smokey succeeded unexpectedly" >&2
  exit 1
fi

echo "signal test complete" > "${SENTINEL}"
if [[ ! -f "${SENTINEL}" ]]; then
  echo "[070-signal-chaos] parent did not continue after signal" >&2
  exit 1
fi
