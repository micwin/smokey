#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if [[ "$(git symbolic-ref --short HEAD)" != "develop" ]]; then
  echo "release.sh: please run from the develop branch" >&2
  exit 1
fi

if ! git diff --quiet --exit-code && true; then
  echo "release.sh: working tree is dirty" >&2
  exit 1
fi

if ! git diff --quiet --exit-code --cached; then
  echo "release.sh: stage is dirty" >&2
  exit 1
fi

SCRIPT_NAME=$(basename "$0")
echo "[${SCRIPT_NAME}] fetching origin"
git fetch origin

checkout_release() {
  if git show-ref --verify --quiet refs/heads/release; then
    git checkout release
    git pull --ff-only origin release
    return
  fi

  if git show-ref --verify --quiet refs/remotes/origin/release; then
    git checkout -b release origin/release
    git pull --ff-only origin release
    return
  fi

  git checkout -b release develop
  git push -u origin release
}

checkout_release

echo "[${SCRIPT_NAME}] merging develop -> release"
git merge --ff-only develop

echo "[${SCRIPT_NAME}] pushing release"
git push origin release

echo "[${SCRIPT_NAME}] returning to develop"
git checkout develop

echo "[${SCRIPT_NAME}] release branch updated. Watch GitHub Actions for deployment."
