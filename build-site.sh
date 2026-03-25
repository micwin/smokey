#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${ROOT_DIR}/site-src"
OUT_DIR="${ROOT_DIR}/site"

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "site-src not found" >&2
  exit 1
fi

VERSION_LINE=$(grep -E '^SMOKEY_VERSION=' "${ROOT_DIR}/smokey.sh" || true)
if [[ -z "${VERSION_LINE}" ]]; then
  echo "unable to read SMOKEY_VERSION from smokey.sh" >&2
  exit 1
fi
SMOKEY_VERSION="${VERSION_LINE#SMOKEY_VERSION=\"}"
SMOKEY_VERSION="${SMOKEY_VERSION%\"}"

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"
cp -R "${SRC_DIR}/assets" "${OUT_DIR}/assets"

ROOT_DIR_ENV="${ROOT_DIR}"
SMOKEY_VERSION_ENV="${SMOKEY_VERSION}"
ROOT_DIR="$ROOT_DIR_ENV" SMOKEY_VERSION="$SMOKEY_VERSION_ENV" python3 <<'PY'
import os
from pathlib import Path

root = Path(os.environ["ROOT_DIR"])
src = root / "site-src" / "index.html"
dst = root / "site" / "index.html"
version = os.environ["SMOKEY_VERSION"]
data = src.read_text()
data = data.replace("{{VERSION}}", version)
dst.write_text(data)
PY

echo "Built site with Smokey ${SMOKEY_VERSION} -> ${OUT_DIR}"
