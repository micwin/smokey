#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_TEST_DIR:?SMOKEY_TEST_DIR missing for directory entry}"
: "${SMOKEY_TEST_ROOT:?SMOKEY_TEST_ROOT not set}"
: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR not set}"

PROJECT_ROOT="$(cd "${SMOKEY_TEST_ROOT}/.." && pwd)"
INNER_TESTS="${SMOKEY_STATE_DIR}/subdir-tests"
rm -rf "${INNER_TESTS}"
mkdir -p "${INNER_TESTS}"

SUPPORT_DIR="${SMOKEY_STATE_DIR}/subdir-support"
mkdir -p "${SUPPORT_DIR}"

HELPER_FILE="${SUPPORT_DIR}/helpers.sh"
EXIT_FILE="${SUPPORT_DIR}/exitlib.sh"
RETURN_FILE="${SUPPORT_DIR}/returnlib.sh"
SENTINEL="${SUPPORT_DIR}/subdir-ok"

cat > "${HELPER_FILE}" <<'EOF'
#!/usr/bin/env bash
havoc_expect_eq() {
  local actual="$1"
  local expected="$2"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "[havoc helper] expected '${expected}' got '${actual}'" >&2
    exit 1
  fi
}
export HAVOC_HELPERS_SOURCED=1
export HAVOC_SHARED_DEFAULT="shared"
EOF

cat > "${EXIT_FILE}" <<'EOF'
echo "[havoc exitlib] firing exit 37" >&2
exit 37
EOF

cat > "${RETURN_FILE}" <<'EOF'
HAVOC_RETURNED_VALUE="returnlib"
return 0
EOF

mkdir -p "${INNER_TESTS}/010-env-source" \
         "${INNER_TESTS}/020-source-exit" \
         "${INNER_TESTS}/030-sourced-trap"

cat > "${INNER_TESTS}/010-env-source/run.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ -v SMOKEY_TEST_DIR ]] || { echo "[subdir] SMOKEY_TEST_DIR unset" >&2; exit 1; }
[[ -v HAVOC_SUPPORT_DIR ]] || { echo "[subdir] HAVOC_SUPPORT_DIR missing" >&2; exit 1; }
source "${HAVOC_SUPPORT_DIR}/helpers.sh"
havoc_expect_eq "${HAVOC_HELPERS_SOURCED}" "1"
havoc_expect_eq "${HAVOC_SHARED_DEFAULT}" "shared"
export HAVOC_CASE_VAR="case-010"
source "${HAVOC_SUPPORT_DIR}/returnlib.sh"
havoc_expect_eq "${HAVOC_RETURNED_VALUE}" "returnlib"
EOF

cat > "${INNER_TESTS}/020-source-exit/run.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ -v HAVOC_SUPPORT_DIR ]] || { echo "[subdir] HAVOC_SUPPORT_DIR missing" >&2; exit 1; }
source "${HAVOC_SUPPORT_DIR}/helpers.sh"
set +e
( source "${HAVOC_SUPPORT_DIR}/exitlib.sh" )
status=$?
set -e
if [[ ${status} -ne 37 ]]; then
  echo "[subdir] expected exit 37 got ${status}" >&2
  exit 1
fi
havoc_expect_eq "${HAVOC_HELPERS_SOURCED}" "1"
EOF

cat > "${INNER_TESTS}/030-sourced-trap/run.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ -v HAVOC_SUPPORT_DIR ]] || { echo "[subdir] HAVOC_SUPPORT_DIR missing" >&2; exit 1; }
source "${HAVOC_SUPPORT_DIR}/helpers.sh"
trap 'echo "[subdir] trap cleanup" >&2' EXIT
source "${HAVOC_SUPPORT_DIR}/returnlib.sh"
havoc_expect_eq "${HAVOC_RETURNED_VALUE}" "returnlib"
EOF

chmod +x "${INNER_TESTS}/010-env-source/run.sh" \
          "${INNER_TESTS}/020-source-exit/run.sh" \
          "${INNER_TESTS}/030-sourced-trap/run.sh"

export HAVOC_SUPPORT_DIR="${SUPPORT_DIR}"

LOG_FILE="${SUPPORT_DIR}/inner-smokey.log"
if ! "${PROJECT_ROOT}/smokey.sh" --tests-dir "${INNER_TESTS}" >"${LOG_FILE}" 2>&1; then
  cat "${LOG_FILE}" >&2
  echo "[080-subdir-havoc] nested smokey run failed" >&2
  exit 1
fi

touch "${SENTINEL}"
