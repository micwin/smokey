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

SUITE_DIR="${TMP_DIR}/env-restore"
mkdir -p "${SUITE_DIR}"

ORIG_PATH="${PATH}"
ORIG_TEST_ROOT="${SMOKEY_TEST_ROOT}"
ORIG_TEST_SCRIPT="${SMOKEY_TEST_SCRIPT}"
ORIG_SKIP_CODE="${SMOKEY_SKIP_CODE}"
ORIG_SHELLOPTS="${SHELLOPTS:-}"
if [[ -v SMOKEY_TEST_DIR ]]; then
  ORIG_TEST_DIR="${SMOKEY_TEST_DIR}"
  TEST_DIR_SET=true
else
  ORIG_TEST_DIR=""
  TEST_DIR_SET=false
fi
unset -f _smokey_child_injected_var 2>/dev/null || true
unset _SMOKEY_CHILD_SENTINEL 2>/dev/null || true

cat > "${SUITE_DIR}/010-mutant.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

trap '
  export PATH="/tmp/trap-path"
  export SMOKEY_TEST_ROOT="/tmp/trap-root"
  export SMOKEY_TEST_SCRIPT="/tmp/trap-script"
  export SMOKEYSkip="trap"
  export SMOKEY_SKIP_CODE=42
  export _SMOKEY_CHILD_SENTINEL="trap"
' EXIT

export PATH="/tmp/mutated-path"
export SMOKEY_TEST_ROOT="/tmp/mutated-root"
export SMOKEY_TEST_SCRIPT="/tmp/mutated-script"
export SMOKEY_SKIP_CODE=41
export SMOKEY_TEST_DIR="/tmp/mutated-dir"
_smokey_child_injected_var="from-child"
EOF
chmod +x "${SUITE_DIR}/010-mutant.sh"

if ! "${PROJECT_ROOT}/smokey" --tests-dir "${SUITE_DIR}"; then
  echo "[030-env-restore] nested smokey run failed" >&2
  exit 1
fi

if [[ "${PATH}" != "${ORIG_PATH}" ]]; then
  echo "[030-env-restore] PATH leaked from child" >&2
  exit 1
fi

if [[ "${SMOKEY_TEST_ROOT}" != "${ORIG_TEST_ROOT}" ]]; then
  echo "[030-env-restore] SMOKEY_TEST_ROOT changed" >&2
  exit 1
fi

if [[ "${SMOKEY_TEST_SCRIPT}" != "${ORIG_TEST_SCRIPT}" ]]; then
  echo "[030-env-restore] SMOKEY_TEST_SCRIPT changed" >&2
  exit 1
fi

if [[ "${SMOKEY_SKIP_CODE}" != "${ORIG_SKIP_CODE}" ]]; then
  echo "[030-env-restore] SMOKEY_SKIP_CODE changed" >&2
  exit 1
fi

if [[ ":${SHELLOPTS:-}:" != *":errexit:"* ]]; then
  echo "[030-env-restore] errexit not restored" >&2
  exit 1
fi

if [[ ":${SHELLOPTS:-}:" != *":nounset:"* ]]; then
  echo "[030-env-restore] nounset not restored" >&2
  exit 1
fi

if [[ ":${SHELLOPTS:-}:" != *":pipefail:"* ]]; then
  echo "[030-env-restore] pipefail not restored" >&2
  exit 1
fi

if [[ "${TEST_DIR_SET}" == "true" ]]; then
  if [[ ! -v SMOKEY_TEST_DIR ]]; then
    echo "[030-env-restore] SMOKEY_TEST_DIR lost" >&2
    exit 1
  fi
  if [[ "${SMOKEY_TEST_DIR}" != "${ORIG_TEST_DIR}" ]]; then
    echo "[030-env-restore] SMOKEY_TEST_DIR changed" >&2
    exit 1
  fi
else
  if [[ -v SMOKEY_TEST_DIR ]]; then
    echo "[030-env-restore] SMOKEY_TEST_DIR unexpectedly set" >&2
    exit 1
  fi
fi

if [[ -v _smokey_child_injected_var ]]; then
  echo "[030-env-restore] child-defined variable leaked" >&2
  exit 1
fi

if [[ -v _SMOKEY_CHILD_SENTINEL ]]; then
  echo "[030-env-restore] trap variables leaked" >&2
  exit 1
fi
