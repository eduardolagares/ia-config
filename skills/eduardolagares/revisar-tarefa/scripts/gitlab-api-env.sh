#!/usr/bin/env bash
# Carrega env da skill gitlab-api (repo ou install). Usar: source "$(dirname "$0")/gitlab-api-env.sh"
set -euo pipefail

_gitlab_api_env_candidates() {
  local script_dir="$1"
  local repo_env
  repo_env="$(cd "${script_dir}/../../gitlab-api/scripts" 2>/dev/null && pwd)/gitlab-api-env.sh" || true
  printf '%s\n' \
    "${repo_env}" \
    "${HOME}/.agents/skills/eduardolagares/gitlab-api/scripts/gitlab-api-env.sh" \
    "${HOME}/.cursor/skills/eduardolagares/gitlab-api/scripts/gitlab-api-env.sh" \
    "${HOME}/.agents/skills/gitlab-api/scripts/gitlab-api-env.sh" \
    "${HOME}/.cursor/skills/gitlab-api/scripts/gitlab-api-env.sh"
}

_gitlab_api_load_env() {
  local script_dir="$1"
  local candidate
  while IFS= read -r candidate; do
    [[ -n "${candidate}" && -f "${candidate}" ]] || continue
    # shellcheck source=/dev/null
    source "${candidate}"
    return 0
  done < <(_gitlab_api_env_candidates "${script_dir}")
  echo "FAIL: gitlab-api-env.sh não encontrado — instale skill gitlab-api (ia-config install)" >&2
  return 1
}

_CALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Use: source ${BASH_SOURCE[0]}" >&2
  exit 1
fi

_gitlab_api_load_env "${_CALLER_DIR}"
