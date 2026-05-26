#!/usr/bin/env bash
# Valida GITLAB_TOKEN (env) + REST API GitLab. Saída: OK ou FAIL.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=gitlab-api-env.sh
source "${SCRIPT_DIR}/gitlab-api-env.sh"

command -v jq >/dev/null 2>&1 || {
  echo "FAIL: jq não instalado (brew install jq)" >&2
  exit 1
}

if [[ -z "${GITLAB_TOKEN:-}" ]]; then
  echo "FAIL: GITLAB_TOKEN ausente no ambiente"
  echo "FIX:  export GITLAB_TOKEN=\"glpat-...\" em ~/.zshrc (PAT em gitlab.baladapp.com.br, escopo api)"
  exit 1
fi

if gitlab_api_is_cursor_agent_shell; then
  echo "WARN: shell do agente Cursor — curl pode falhar; use cache/hook ou ctx_execute"
  echo "OK:   GITLAB_TOKEN definido (${#GITLAB_TOKEN} chars)"
  exit 0
fi

set +e
user_json="$(gitlab_api_curl "${GITLAB_API_BASE}/user" 2>/dev/null)"
ec=$?
set -e

if [[ "${ec}" -eq 0 ]] && echo "${user_json}" | jq -e '.username' >/dev/null 2>&1; then
  user="$(echo "${user_json}" | jq -r '.username')"
  host="${GITLAB_API_BASE%/api/v4}"
  echo "OK: GitLab REST API em ${host} (user=${user})"
  exit 0
fi

echo "FAIL: GITLAB_TOKEN presente mas API não respondeu (GET /user)"
echo "      Verifique GITLAB_TOKEN (expirado/escopo api). VPN já deve estar ativa no Mac do executador."
exit 1
