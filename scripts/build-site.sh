#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/site-src"
OUT_DIR="${ROOT_DIR}/site"

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "site-src not found" >&2
  exit 1
fi

VERSION_LINE=$(grep -E '^SMOKEY_VERSION=' "${ROOT_DIR}/smokey" || true)
if [[ -z "${VERSION_LINE}" ]]; then
  echo "unable to read SMOKEY_VERSION from smokey" >&2
  exit 1
fi
SMOKEY_VERSION="${VERSION_LINE#SMOKEY_VERSION=\"}"
SMOKEY_VERSION="${SMOKEY_VERSION%\"}"

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"
cp -R "${SRC_DIR}/assets" "${OUT_DIR}/assets"

ROOT_DIR_ENV="${ROOT_DIR}"
SMOKEY_VERSION_ENV="${SMOKEY_VERSION}"
for html in "${SRC_DIR}"/*.html; do
  file_name="$(basename "${html}")"
  ROOT_DIR="${ROOT_DIR_ENV}" \
  SMOKEY_VERSION="${SMOKEY_VERSION_ENV}" \
  SRC_FILE="${html}" \
  DST_FILE="${OUT_DIR}/${file_name}" \
  python3 <<'PY'
import os
from pathlib import Path

src = Path(os.environ["SRC_FILE"])
dst = Path(os.environ["DST_FILE"])
version = os.environ["SMOKEY_VERSION"]
text = src.read_text()
text = text.replace("{{VERSION}}", version)
dst.write_text(text)
PY
done

echo "Built site with Smokey ${SMOKEY_VERSION} -> ${OUT_DIR}"
