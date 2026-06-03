# Smokey Agent Help

## Contract

Smokey tests are suite tests, not standalone script tests.

Always run Smokey itself:

```bash
smokey --tests-dir tests.d
```

Do not run individual test scripts directly as a substitute for a Smokey run. Direct execution bypasses runner behavior that is part of the contract: initial teardown, setup ordering, shared env handling, state isolation, fail-fast semantics, final teardown, and summary reporting.

## Suite Model

- Test entries live in `tests.d` unless `--tests-dir` points elsewhere.
- Entries are sorted by name and must start with a three-digit prefix such as `000-setup`, `010-smoke`, or `999-teardown`.
- An entry may be one executable file or one directory containing exactly one executable file.
- `000-*` entries are setup. A setup failure skips later regular tests.
- `999-*` entries are teardown. Teardown runs before the suite and after the suite.
- Put cleanup work only into `999-*` entries. Do not hide cleanup in `000-*`; setup should prepare, not clean.
- Final teardown still runs after failures unless `--preserve` is set.
- Initial teardown is skipped only with `--reuse-state`. Use this deliberately when inspecting or continuing a preserved run.
- Without `--fail-fast`, later regular tests continue after a failure.
- With `--fail-fast`, later regular tests are skipped after the first failure, but teardown still runs.

## Debugging Without Breaking the Suite

If later tests are irrelevant for the current debug cycle, keep running Smokey and temporarily skip those later tests from inside the suite:

```bash
echo "[TEMP DEBUG] skipping this branch while debugging" >&2
exit "${SMOKEY_SKIP_CODE}"
```

Use this only as a temporary edge. Remove it before final verification.

Do not add direct-test-only fallback code just to make a test script runnable by itself. Smokey provides the runtime contract. Tests should assume they are run by Smokey.

## State And Files

- Use `${SMOKEY_STATE_DIR}` for run-local files, sockets, logs, temp data, and generated fixtures.
- Use `${SMOKEY_STATE_DIR}` for files that should survive from one test step to the next within the same Smokey run.
- Use `${SMOKEY_TEST_DIR}` for committed assets that belong to the current directory-based test.
- Use `${SMOKEY_TEST_ROOT}` only when a test must refer to another committed test asset.
- Do not require `.smokey-state` to exist before Smokey starts.
- Do not write transient data into the repository unless the test intentionally creates a committed fixture.
- Do not delete `${SMOKEY_STATE_DIR}` from tests or teardown; Smokey owns it.
- Prefer directory-based tests when several files are part of the same test case. Put committed fixtures, expected outputs, and support scripts next to the runner inside that directory.
- A directory-based test must contain exactly one executable file. Keep that runner small and let it read its local assets through `${SMOKEY_TEST_DIR}`.

## Shared Environment

Smokey sources `${SMOKEY_ENV_FILE}` before each test. Do not edit that file directly.

Use the helpers injected into each test:

```bash
export API_URL="http://127.0.0.1:8080"
smokey_env_save API_URL

smokey_env_unset API_URL
smokey_env_show
```

Use `tests.d/env.preseed` for committed initial shared env values. Include `export` or `unset` lines there. Smokey variables such as `${SMOKEY_STATE_DIR}` are available when the preseed file is sourced.

## Exit Codes

- `0`: pass
- `${SMOKEY_SKIP_CODE}` (default `20`): skip/abort edge managed by Smokey
- any other non-zero status: fail

Use `${SMOKEY_SKIP_CODE}` for temporary debug skipping or intentional suite branches. Use ordinary failure statuses for real assertion failures.

## Agent Rules

- Prefer short, readable tests over clever shell.
- Tests are the first line of documentation for human coders. Every logical 1-34 line block should have a one-line code comment.
- Add a one-line comment whenever a test changes function, especially where a blank line separates two phases.
- Keep test data as committed files inside the test directory instead of large heredocs.
- Do not print secrets or production values.
- Do not use user-global config, user-global temp paths, or production services unless the suite explicitly owns them.
- Do not hide failures by weakening assertions.
- Do not leave temporary debug exits, temporary sleeps, local paths, or direct-test fallbacks in the final change.
- Before reporting done, run the full Smokey suite and confirm the summary and final teardown behavior.

## Final Checklist

Before handing work back:

- No `[TEMP DEBUG]` exits remain.
- No direct-test-only fallback code was added.
- All generated files live under `${SMOKEY_STATE_DIR}` or are intentional committed fixtures.
- Shared env changes use `smokey_env_save`, `smokey_env_unset`, or `env.preseed`.
- The full suite was run through `smokey --tests-dir tests.d`.
- Final teardown ran, unless `--preserve` was intentionally used and reported.
