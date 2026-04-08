# Releasing Smokey

This repository keeps all day-to-day development on `develop`. The `release` branch is special: pushing to it triggers the full automation (tagging, GitHub release, Debian package, and site deployment). Follow the steps below whenever you want to publish a new version.

## 1. Verify develop
- Ensure all desired changes are merged into `develop`.
- Optionally run the smokey self-tests locally: `cd smokey && ./smokey --tests-dir tests.d`.
- If you changed the marketing site, regenerate the static output via `scripts/build-site.sh`. (The GitHub workflow does this again, but running it locally helps catch mistakes.)

## 2. Prepare version bump
- Run `scripts/package-deb.sh` before touching `release`. Without arguments it automatically bumps the patch version (e.g., `0.2.0` → `0.2.1`), rebuilds the site, and drops fresh artifacts into `dist/`. Pass an explicit version (e.g., `./scripts/package-deb.sh 0.3.0`) when you want a minor/major release. Commit the resulting `smokey` change.

## 3. Merge develop into release
- If `release` does not exist yet, create it from develop: `git checkout -b release develop` and push it once.
- Otherwise: `git checkout release && git pull && git merge develop`.

## 4. Push release
- Run `scripts/release.sh`. The script:
  1. Verifies you are on `develop` with a clean working tree.
  2. Checks out (or creates) the `release` branch, updates it with `develop`, and pushes it to origin.
- Once `scripts/release.sh` pushes `release`, GitHub Actions runs `.github/workflows/release.yml`:
  1. Read `SMOKEY_VERSION` from `smokey`.
  2. Execute `scripts/package-deb.sh` (which bumps versions if needed, rebuilds the marketing site, and outputs `dist/smokey_<version>_amd64.deb` plus `dist/smokey_<version>.sh`).
  3. Create/push tag `v<version>`.
  4. Publish a GitHub Release with both artifacts attached.
  5. Deploy the generated `site/` folder to the `pages` branch for GitHub Pages.

## 5. Monitor the workflow
- Check the Actions tab for the `Release Smokey` workflow run. It should finish successfully.
- After success:
  * The GitHub release contains the `.deb` and the raw `smokey` script.
  * https://micwin.github.io/smokey/ shows the updated site (with the new version in download links).

## 6. Optional cleanup
- If you like keeping `release` short-lived, delete it locally/remote: `git checkout develop && git branch -D release && git push origin --delete release`.
- Otherwise, leave it in place; the next release just reuses it.

## Notes
- `scripts/package-deb.sh` is idempotent — it only bumps `SMOKEY_VERSION` when you pass a higher version number. By default it increments the patch number.
- The workflow uses the default `GITHUB_TOKEN` with `contents: write` permission; no extra secrets are required.
- If you ever need to re-run a release (e.g., because an asset was missing), rerun the workflow from the Actions tab (“Re-run all jobs”) **after fixing the issue** on `release`.
