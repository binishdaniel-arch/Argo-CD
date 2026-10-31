#!/usr/bin/env bash
set -euo pipefail
if command -v helm >/dev/null; then helm version --short; exit 0; fi
[[ "$(uname -s)" == Linux ]] || { echo 'On Windows, install Helm and reopen Git Bash. This helper is Linux-only.' >&2; exit 1; }
case "$(uname -m)" in x86_64) arch=amd64 ;; aarch64|arm64) arch=arm64 ;; *) echo 'Unsupported architecture' >&2; exit 1 ;; esac
version=v4.3.0
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
archive="helm-$version-linux-$arch.tar.gz"
curl --fail --location --retry 3 "https://get.helm.sh/$archive" -o "$work/$archive"
checksum="$(curl --fail --silent --show-error --location "https://get.helm.sh/$archive.sha256")"
(cd "$work" && printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check -)
tar -xzf "$work/$archive" -C "$work"
mkdir -p "$HOME/.local/bin"
cp "$work/linux-$arch/helm" "$HOME/.local/bin/helm"
"$HOME/.local/bin/helm" version --short
echo 'Run: export PATH="$HOME/.local/bin:$PATH"'
