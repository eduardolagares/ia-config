#!/usr/bin/env bash
# Delega para skill gitlab-api (GITLAB_TOKEN).
set -euo pipefail
CANON="${HOME}/.agents/skills/gitlab-api/scripts/gitlab-api-mr-ensure.sh"
if [[ ! -f "${CANON}" ]]; then
  echo "FAIL: ${CANON} ausente — instale skill gitlab-api" >&2
  exit 1
fi
exec "${CANON}" "$@"
