#!/usr/bin/env bash
# Resolve path de script na skill gitlab-api (instalada ou repo).
# Uso: source .../_resolve-gitlab-api.sh && gitlab_api_resolve_script gitlab-api-env.sh
set -euo pipefail

gitlab_api_resolve_script() {
  local name="$1"
  local caller_dir="${2:-$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}"
  local repo_script
  repo_script="$(cd "${caller_dir}/../../gitlab-api/scripts" 2>/dev/null && pwd)/${name}" || true

  local -a candidates=(
    "${repo_script}"
    "${HOME}/.agents/skills/eduardolagares/gitlab-api/scripts/${name}"
    "${HOME}/.cursor/skills/eduardolagares/gitlab-api/scripts/${name}"
    "${HOME}/.agents/skills/gitlab-api/scripts/${name}"
    "${HOME}/.cursor/skills/gitlab-api/scripts/${name}"
  )

  local path
  for path in "${candidates[@]}"; do
    if [[ -n "${path}" && -f "${path}" ]]; then
      printf '%s' "${path}"
      return 0
    fi
  done
  return 1
}
