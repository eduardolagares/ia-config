#!/usr/bin/env bash
# Delegates to gitlab-api skill (GITLAB_TOKEN).
CANON="${HOME}/.agents/skills/gitlab-api/scripts/gitlab-api-env.sh"
if [[ ! -f "${CANON}" ]]; then
  echo "FAIL: ${CANON} ausente — instale skill gitlab-api" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${CANON}"
