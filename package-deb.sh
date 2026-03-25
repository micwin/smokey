#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
PKG_DIR="${DIST_DIR}/smokey-deb"
ARCH="amd64"
mkdir -p "${DIST_DIR}"

CURRENT_VERSION=$(grep -o 'SMOKEY_VERSION="[0-9]\+\.[0-9]\+\.[0-9]\+"' "${ROOT_DIR}/smokey.sh" | cut -d'"' -f2)
if [[ -z "${CURRENT_VERSION}" ]]; then
  echo "Unable to detect current version" >&2
  exit 1
fi

NEW_VERSION="${CURRENT_VERSION}"
if [[ $# -gt 0 ]]; then
  NEW_VERSION="$1"
else
  IFS='.' read -r major minor patch <<<"${CURRENT_VERSION}"
  patch=$((patch + 1))
  NEW_VERSION="${major}.${minor}.${patch}"
fi

if [[ ! "${NEW_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version: ${NEW_VERSION}" >&2
  exit 1
fi

if [[ "${NEW_VERSION}" != "${CURRENT_VERSION}" ]]; then
  sed -i "s/SMOKEY_VERSION=\"${CURRENT_VERSION}\"/SMOKEY_VERSION=\"${NEW_VERSION}\"/" "${ROOT_DIR}/smokey.sh"
fi

"${ROOT_DIR}/build-site.sh"

rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}/DEBIAN" "${PKG_DIR}/usr/local/bin" "${PKG_DIR}/usr/share/doc/smokey"
install -m 0755 "${ROOT_DIR}/smokey.sh" "${PKG_DIR}/usr/local/bin/smokey"
install -m 0644 "${ROOT_DIR}/README.md" "${PKG_DIR}/usr/share/doc/smokey/README"

cat > "${PKG_DIR}/DEBIAN/control" <<CTRL
Package: smokey
Version: ${NEW_VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: Smokey
Description: Smokey smoke-test runner
CTRL

cd "${PKG_DIR}"
find usr -type d -exec chmod 755 {} +
find usr -type f -exec chmod 755 {} +
chmod 755 usr/local/bin/smokey
chmod 644 usr/share/doc/smokey/README

cd "${DIST_DIR}"
dpkg-deb --build "smokey-deb" "smokey_${NEW_VERSION}_${ARCH}.deb"

echo "Built smokey ${NEW_VERSION}"EOF
