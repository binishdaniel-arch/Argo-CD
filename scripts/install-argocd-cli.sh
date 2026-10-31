#!/usr/bin/env bash
set -euo pipefail
version=v3.5.6
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) asset=argocd-windows-amd64.exe; output=argocd.exe ;;
  Linux)
    case "$(uname -m)" in x86_64) arch=amd64 ;; aarch64|arm64) arch=arm64 ;; *) echo 'Unsupported CPU architecture' >&2; exit 1 ;; esac
    asset="argocd-linux-$arch"; output=argocd ;;
  *) echo 'This helper supports Git Bash on Windows x64 and Linux Bash.' >&2; exit 1 ;;
esac
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
curl --fail --location --retry 3 "https://github.com/argoproj/argo-cd/releases/download/$version/$asset" -o "$work/$asset"
curl --fail --silent --show-error --location "https://github.com/argoproj/argo-cd/releases/download/$version/cli_checksums.txt" -o "$work/checksums.txt"
(cd "$work" && grep -E "[[:space:]]+$asset$" checksums.txt | sha256sum --check -)
install_dir="${LAB_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$install_dir"
cp "$work/$asset" "$install_dir/$output"
chmod +x "$install_dir/$output"
"$install_dir/$output" version --client --short
echo 'Next: export PATH="$HOME/.local/bin:$PATH"'
