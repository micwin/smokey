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

SUITE_DIR="${TMP_DIR}/recursive-suite"
LEVELB_DIR="${SUITE_DIR}/level-b"
LEVELB_TESTS="${LEVELB_DIR}/tests.d"
LEVELC_DIR="${SUITE_DIR}/level-c/tests.d"
LEVELC_STATE="${SUITE_DIR}/level-c.state"

mkdir -p "${LEVELB_TESTS}" "${LEVELC_DIR}/000-setup" "${LEVELC_DIR}/999-teardown"

cat > "${LEVELC_DIR}/000-setup/run.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
STATE_FILE="${LEVELC_STATE}"
echo "[level-c] preparing state" > "\${STATE_FILE}"
EOF

cat > "${LEVELC_DIR}/010-check.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
STATE_FILE="${LEVELC_STATE}"
if [[ ! -f "\${STATE_FILE}" ]]; then
  echo "[level-c] state missing" >&2
  exit 1
fi
EOF

cat > "${LEVELC_DIR}/999-teardown/run.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
STATE_FILE="${LEVELC_STATE}"
rm -f "\${STATE_FILE}"
EOF

cat > "${LEVELB_TESTS}/010-nested.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="${PROJECT_ROOT}"
LEVELC_DIR="${LEVELC_DIR}"
STATE_FILE="${LEVELC_STATE}"
if ! "\${PROJECT_ROOT}/smokey.sh" --tests-dir "\${LEVELC_DIR}" --preserve; then
  echo "[level-b] preserve run failed" >&2
  exit 1
fi
if [[ ! -f "\${STATE_FILE}" ]]; then
  echo "[level-b] state missing after preserve run" >&2
  exit 1
fi
if ! "\${PROJECT_ROOT}/smokey.sh" --tests-dir "\${LEVELC_DIR}" --reuse-state; then
  echo "[level-b] reuse-state run failed" >&2
  exit 1
fi
if [[ -f "\${STATE_FILE}" ]]; then
  echo "[level-b] state not cleaned after reuse run" >&2
  exit 1
fi
EOF

chmod +x "${LEVELC_DIR}/000-setup/run.sh" \
          "${LEVELC_DIR}/010-check.sh" \
          "${LEVELC_DIR}/999-teardown/run.sh" \
          "${LEVELB_TESTS}/010-nested.sh"

if ! "${PROJECT_ROOT}/smokey.sh" --tests-dir "${LEVELB_TESTS}"; then
  echo "[050-recursive] nested smokey run failed" >&2
  exit 1
fi
