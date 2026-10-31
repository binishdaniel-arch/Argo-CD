#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
repo="${1:-}"
[[ "$repo" =~ ^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(\.git)?$ ]] || { echo 'Pass your public HTTPS GitHub repository URL' >&2; exit 1; }
repo="${repo%.git}.git"
for file in gitops/demo/application.yaml gitops/bootstrap/project.yaml gitops/applications/*.yaml; do
  sed -i -E "s|https://github.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+|$repo|g" "$file"
done
echo 'Updated project and Application sources. Review, commit/push before applying the Application.'
