#!/usr/bin/env bash
set -euo pipefail

: "${SMOKEY_TEST_ROOT:?SMOKEY_TEST_ROOT is required}"
PROJECT_ROOT="$(cd "${SMOKEY_TEST_ROOT}/.." && pwd)"
: "${SMOKEY_STATE_DIR:?SMOKEY_STATE_DIR is required}"
SUITE_DIR="${SMOKEY_STATE_DIR}/initial-summary"

mkdir -p "${SUITE_DIR}/000-setup" "${SUITE_DIR}/999-teardown"

cat > "${SUITE_DIR}/000-setup/run.sh" <<'SETUP'
#!/usr/bin/env bash
set -euo pipefail
echo "[initial-summary] setup"
SETUP

cat > "${SUITE_DIR}/010-pass.sh" <<'PASS'
#!/usr/bin/env bash
set -euo pipefail
echo "[initial-summary] regular test"
PASS

cat > "${SUITE_DIR}/999-teardown/run.sh" <<'TEARDOWN'
#!/usr/bin/env bash
set -euo pipefail
echo "[initial-summary] teardown"
TEARDOWN

chmod +x "${SUITE_DIR}/000-setup/run.sh" \
  "${SUITE_DIR}/010-pass.sh" \
  "${SUITE_DIR}/999-teardown/run.sh"

if ! OUTPUT="$(${PROJECT_ROOT}/smokey --tests-dir "${SUITE_DIR}" 2>&1)"; then
  echo "[initial-summary] nested smokey run failed" >&2
  printf '%s\n' "${OUTPUT}" >&2 || true
  exit 1
fi

printf '%s\n' "${OUTPUT}"

if grep -q "999-teardown : skipped" <<<"${OUTPUT}"; then
  echo "[initial-summary] expected initial teardown to report ok" >&2
  exit 1
fi

if ! grep -q "999-teardown : ok" <<<"${OUTPUT}"; then
  echo "[initial-summary] missing ok status for initial teardown" >&2
  exit 1
fi

if ! grep -q "final teardown:" <<<"${OUTPUT}"; then
  echo "[initial-summary] missing final teardown summary" >&2
  exit 1
fi

FINAL_STATUS="$(awk '/final teardown:/ {getline; print; exit}' <<<"${OUTPUT}" || true)"
if [[ "${FINAL_STATUS}" != *"999-teardown : ok"* ]]; then
  echo "[initial-summary] final teardown did not report ok" >&2
  exit 1
fi
