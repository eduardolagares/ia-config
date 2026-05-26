#!/usr/bin/env bash
# Delega para skill gitlab-api (repo ou install).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
repo_script="$(cd "${SCRIPT_DIR}/../../gitlab-api/scripts" 2>/dev/null && pwd)/gitlab-api-mr-ensure.sh" || true

for candidate in \
  "${repo_script}" \
  "${HOME}/.agents/skills/eduardolagares/gitlab-api/scripts/gitlab-api-mr-ensure.sh" \
  "${HOME}/.cursor/skills/eduardolagares/gitlab-api/scripts/gitlab-api-mr-ensure.sh" \
  "${HOME}/.agents/skills/gitlab-api/scripts/gitlab-api-mr-ensure.sh" \
  "${HOME}/.cursor/skills/gitlab-api/scripts/gitlab-api-mr-ensure.sh"; do
  if [[ -n "${candidate}" && -x "${candidate}" ]]; then
    exec "${candidate}" "$@"
  fi
  if [[ -n "${candidate}" && -f "${candidate}" ]]; then
    exec bash "${candidate}" "$@"
  fi
done

echo "FAIL: gitlab-api-mr-ensure.sh não encontrado — instale skill gitlab-api (ia-config install)" >&2
exit 1
