#!/usr/bin/env bash
# Ambiente compartilhado para scripts glab da skill /revisar-tarefa.
# Uso: source "$(dirname "$0")/glab-env.sh"
set -euo pipefail

GLAB_DEFAULT_HOST="${GLAB_DEFAULT_HOST:-gitlab.baladapp.com.br}"

# Não source ~/.zshrc aqui: com set -e o zshrc costuma abortar o script sem mensagem.
# glab usa token/host em ~/Library/Application Support/glab-cli/config.yml

if ! command -v glab >/dev/null 2>&1; then
  echo "FAIL: glab não instalado (brew install glab)" >&2
  exit 1
fi

glab_configured_host="$(glab config get host -g 2>/dev/null || true)"
if [[ "${glab_configured_host}" != "${GLAB_DEFAULT_HOST}" ]]; then
  echo "WARN: host global do glab é '${glab_configured_host:-vazio}'; esperado ${GLAB_DEFAULT_HOST}" >&2
  echo "      Rode: glab config set host ${GLAB_DEFAULT_HOST} -g" >&2
fi

# Terminal do agente Cursor injeta proxy local → API GitLab retorna 403.
glab_is_cursor_agent_shell() {
  [[ -n "${__CURSOR_SANDBOX_ENV_RESTORE:-}" ]] \
    || [[ "${HTTP_PROXY:-}" == *"127.0.0.1"* ]] \
    || [[ "${ALL_PROXY:-}" == *"127.0.0.1"* ]]
}

glab_print_run_in_user_terminal() {
  local cmd="$1"
  echo "GLAB_RUN_IN_USER_TERMINAL=1" >&2
  echo "Execute no seu Terminal (fora do agente) e cole a saída no chat:" >&2
  echo "${cmd}" >&2
}

# Executa glab; em shell do agente, tenta sem proxy. Se falhar, pede terminal do usuário.
glab_exec() {
  local -a cmd=(glab "$@")
  local printable
  printf -v printable '%q ' "${cmd[@]}"

  if glab_is_cursor_agent_shell; then
    if env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u http_proxy -u https_proxy \
      -u all_proxy -u GIT_HTTP_PROXY -u GIT_HTTPS_PROXY -u SOCKS_PROXY -u SOCKS5_PROXY \
      "${cmd[@]}"; then
      return 0
    fi
    glab_print_run_in_user_terminal "${printable}"
    return 2
  fi

  "${cmd[@]}"
}
