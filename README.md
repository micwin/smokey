# Smokey

Smokey is a lightweight smoke-test runner for mono-repo projects. It expects a directory of numbered test entries (default `tests.d` relative to the project root) and executes them sequentially, supporting both single scripts and directory-based runners.

## Features
- Alphabetical execution order based on filename (e.g., `000-setup`, `010-smoke`, `999-teardown`).
- Special handling for setup/teardown: `000-*` entries run first and can abort later tests by exiting with `SMOKEY_SKIP_CODE` (default `20`), while `999-*` entries always run even if earlier steps failed.
- Exports lightweight environment variables (`SMOKEY_TEST_ROOT`, `SMOKEY_TEST_SCRIPT`, optional `SMOKEY_TEST_DIR`, `SMOKEY_SKIP_CODE`) so test scripts can find their assets and communicate state.
- Works with both standalone executable files and directories containing exactly one executable file, making it easy to package complex test logic.
- Summarizes results at the end, listing only non-OK outcomes to keep logs concise.
- Debug-friendly flags: `--fail-fast` interrupts the suite after the first failure (teardown still runs) and `--preserve` skips the final teardown pass so you can inspect artifacts. `--reuse-state` skips the initial cleanup pass if you deliberately keep a previous `.testrun/`.
- Provides an isolated scratch directory per run (`SMOKEY_STATE_DIR`) so nested Smokey invocations never overwrite each other’s temporary files.

## Usage
```
# From a project directory that contains tests.d
smokey --tests-dir tests.d

# Override directory explicitly (relative or absolute)
path/to/smokey --tests-dir ./custom-tests

# Fail fast on the first error
smokey --fail-fast --tests-dir tests.d

# Keep the environment around for debugging (skip final teardown)
smokey --preserve --tests-dir tests.d

# Reuse an existing test state (skip initial teardown)
smokey --reuse-state --tests-dir tests.d

# Run smokey's own self-tests (wrapper calls the checked-out repo runner)
cd smokey
smokey --tests-dir tests.d

# Run the underlying repo-pinned suite directly
smokey --tests-dir tests.d
```

Source `enter.sh` at the repo root (`. ./enter.sh`) to automatically add `smokey/` to your `PATH`, then call `smokey` without specifying the full path.

`tests.d/` now contains the entire suite (setup, feature tests, teardown). Some entries spin up nested Smokey runs in temporary subdirectories, mirroring how downstream projects might orchestrate their own suites.

## Test directory layout
- Place numbered scripts or directories under `tests.d/`. Example:
- `000-setup/run.sh` — prepares the environment; if it exits with `SMOKEY_SKIP_CODE` the rest of the suite is skipped (except teardown).
  - `010-smoke.sh` — regular smoke test.
  - `020-api-health.sh` — another test.
  - `999-teardown/run.sh` — always executed to clean up resources.
- Each directory-based entry must contain exactly one executable file; Smokey treats that file as the runner.
- Teardown scripts (`999-*`) should be tolerant (e.g., `rm -rf` on missing directories) and only return a non-zero exit code when the failure truly blocks the next run. Smokey calls them before the suite to clean up stale state, so spurious errors here prevent tests from starting.

## Environment variables
Each test executes inside a subshell with the following read-only exports:
- `SMOKEY_TEST_ROOT` — absolute path to the current `tests.d` directory.
- `SMOKEY_TEST_SCRIPT` — path to the executable being invoked.
- `SMOKEY_TEST_DIR` — set only when the entry is a directory (contains the executable).
- `SMOKEY_SKIP_CODE` — exit code (default `20`) that signals Smokey to skip the remaining regular tests (teardown still runs).
- `SMOKEY_STATE_DIR` — per-run scratch directory (Smokey creates a fresh, random directory under `tests.d/.smokey-state/` for each invocation). Use this if your tests need to share temporary files so nested Smokey calls do not trample each other.
- `SMOKEY_STATE_PARENT` — parent directory that contains all run-specific state directories.
- `SMOKEY_ENV_FILE` — shared shell snippet sourced before every test. Use `smokey_env_save NAME` to persist a currently exported variable across later tests, `smokey_env_unset NAME` to remove it again, and `smokey_env_show` to print the current file for debugging.

Smokey removes the per-run state directory automatically unless `--preserve` is passed, so debugging sessions can keep artifacts by reusing that flag.

### Sharing env values using `$SMOKEY_ENV_FILE`

Smokey automatically sources `${SMOKEY_ENV_FILE}` before each test. You never touch the file directly; instead call the helpers that Smokey injects into every test environment:

```bash
# 000-setup/run.sh
#!/usr/bin/env bash
set -euo pipefail

API_TOKEN="$(vault issue-token)"
export API_TOKEN
smokey_env_save API_TOKEN   # persists the export into shared.env

TMPDIR="${SMOKEY_STATE_DIR}/daemon"
mkdir -p "$TMPDIR"
smokey_env_save TMPDIR
```

```bash
# 010-smoke.sh (later test)
#!/usr/bin/env bash
set -euo pipefail

: "${API_TOKEN:?API token missing}"
curl -H "Authorization: Bearer ${API_TOKEN}" \
     --unix-socket "${TMPDIR}/sock" \
     http://unix/health

# stop sharing once you no longer need it
smokey_env_unset API_TOKEN
```

- `smokey_env_save NAME` writes the current value of `$NAME` into the shared file so the next test sees the same export.
- `smokey_env_unset NAME` both unsets the variable for the current shell **and** records the removal for later tests.
- `smokey_env_show` dumps the current file (useful while debugging).

The shared env file lives under `tests.d/.smokey-state/<run-id>/shared.env`. Smokey creates and cleans it automatically—teardown scripts should never delete `${SMOKEY_STATE_DIR}` (unless you intentionally pass `--preserve` to keep state around).

#### Pre-seeding the shared env

Smokey automatically appends `tests.d/env.preseed` to the shared env file before the first test runs. Keep that file under version control with the exports/unsets you want available everywhere:

```bash
# tests.d/env.preseed
export TMPDIR="${SMOKEY_STATE_DIR}/daemon"
mkdir -p "${TMPDIR}"
export LOG_LEVEL=debug
export API_BASE_URL="https://api.example.test"
unset LEGACY_FLAG
```

- Always include `export` (or `unset`) so later tests inherit the values when `SMOKEY_ENV_FILE` is sourced; plain assignments stay local to that test shell.
- Smokey-defined variables such as `SMOKEY_STATE_DIR` and `SMOKEY_TEST_ROOT` are already available when the preseed file runs, so you can reference them directly to derive directories.

Each test sees those defaults immediately, and you can still call `smokey_env_save` / `smokey_env_unset` later to record dynamic values. No extra scripting is required—the convention file is picked up automatically during every run.

Smokey automatically runs any `999-*` entries once before the suite (unless `--reuse-state` is passed) to clean stale state, and again at the end unless `--preserve` is set. Tests can additionally create their own state files (e.g., `.testrun/`) and share metadata via environment files, as demonstrated by `vaultline/tests.d/`.

## Release 0.2.0
- Hardened the runner by executing every test in a separate `env -i bash` subprocess and only allowing predeclared environment variables to persist across tests.
- Regenerate helper and loader scripts per test so malicious suites cannot tamper with later runs.
- Added path, zombie, and state-directory havoc suites (plus supporting fixtures) to continuously verify that Smokey cleans up PATH poisoning, background jobs, and deleted env files.

## Example
See `vaultline/tests.d/` for a reference suite:
- `000-setup/run.sh` boots the vaultline daemon and writes connection details to `.testrun/env`.
- `010-smoke.sh` runs `go test ./...` and verifies CLI secret creation.
- `020-api-health.sh` checks CLI and REST health endpoints.
- `999-teardown/run.sh` removes `.testrun/` and stops the daemon.

Run it via:
```
cd vaultline
smokey --tests-dir tests.d
```

## Website & releases
- Edit the marketing site under `site-src/` (placeholders such as `{{VERSION}}` are replaced automatically), then run `scripts/build-site.sh` to regenerate the static assets in `site/`.
- `scripts/package-deb.sh` bumps `SMOKEY_VERSION`, rebuilds the site, and creates `dist/smokey_<version>_amd64.deb`.
- `scripts/release.sh` checks out the `release` branch, syncs it with `develop`, and pushes it so the GitHub Actions release workflow publishes the new version (artifacts + Pages site).
- Pushing the `release` branch triggers the automated GitHub Actions workflow:
  1. determine the version from `smokey`
  2. run `package-deb.sh` and package the `.deb`
  3. tag the commit (`v<version>`) and publish a GitHub Release with the Debian package
  4. deploy the generated site (`site/`) to the `pages` branch
- Releases also attach a standalone `smokey_<version>` script so users can download and run the CLI without the `.deb` package.
