#!/usr/bin/env bash
# Valida glab + host padrão Baladapp. Saída: OK ou FAIL.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=glab-env.sh
source "${SCRIPT_DIR}/glab-env.sh"

command -v jq >/dev/null 2>&1 || {
  echo "FAIL: jq não instalado (brew install jq)" >&2
  exit 1
}

host="$(glab config get host -g 2>/dev/null || true)"
if [[ "${host}" != "${GLAB_DEFAULT_HOST}" ]]; then
  echo "FAIL: glab host global='${host:-vazio}' (esperado ${GLAB_DEFAULT_HOST})"
  echo "FIX:  glab config set host ${GLAB_DEFAULT_HOST} -g"
  exit 1
fi

if glab_is_cursor_agent_shell; then
  echo "WARN: shell do agente Cursor — glab deve rodar no Terminal do usuário"
  echo "OK:   glab instalado; host=${host}; token presente no config"
  echo "      Teste no seu Terminal: glab auth status && glab repo list --member --per-page 3"
  exit 0
fi

auth_out="$(glab auth status 2>&1)" || true
has_token=0
echo "${auth_out}" | grep -q "Token found" && has_token=1

# glab api: saída JSON por padrão (--output json). NÃO usar -F json (flag de form, quebra o comando).
api_user_ok=0
if user_json="$(glab api user 2>/dev/null)" && echo "${user_json}" | jq -e '.username' >/dev/null 2>&1; then
  api_user_ok=1
  user="$(echo "${user_json}" | jq -r '.username')"
  echo "OK: glab autenticado em ${GLAB_DEFAULT_HOST} (user=${user})"
  exit 0
fi

# Fallback: mesmo teste que você já validou manualmente
if repos_json="$(glab repo list --member --per-page 1 -F json 2>/dev/null)" \
  && echo "${repos_json}" | jq -e 'type == "array"' >/dev/null 2>&1; then
  count="$(echo "${repos_json}" | jq 'length')"
  echo "OK: glab API em ${GLAB_DEFAULT_HOST} (repo list --member OK, amostra=${count} projeto(s))"
  exit 0
fi

if [[ "${has_token}" -eq 1 ]]; then
  echo "FAIL: token existe no config, mas a API GitLab não respondeu (user/repo list falharam)"
  echo "      Rode: glab auth status"
  if echo "${auth_out}" | grep -qi "forbidden\|401\|unauthorized"; then
    echo "      Provável token expirado/revogado — crie novo PAT e:"
    echo "      glab auth login --hostname ${GLAB_DEFAULT_HOST}"
  fi
  exit 1
fi

echo "FAIL: glab sem token em ${GLAB_DEFAULT_HOST}"
echo "FIX:  glab auth login --hostname ${GLAB_DEFAULT_HOST}"
exit 1
