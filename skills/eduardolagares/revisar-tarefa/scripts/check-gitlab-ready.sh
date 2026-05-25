#!/usr/bin/env bash
# Diagnóstico: GITLAB_TOKEN, REST API, hook e cache (passo 3 /revisar-tarefa).
# Uso: check-gitlab-ready.sh [--branch BR] [--titulo T]
set -euo pipefail

BRANCH=""
TITULO=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="${HOME}/.cursor/hooks/revisar-tarefa-prefetch-diff.sh"
CACHE_SCRIPT="${SCRIPT_DIR}/read-diff-bundle-cache.sh"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) BRANCH="${2:-}"; shift 2 ;;
    --titulo) TITULO="${2:-}"; shift 2 ;;
    -h|--help)
      echo "Uso: check-gitlab-ready.sh [--branch BR] [--titulo T]"
      exit 0
      ;;
    *) echo "Arg desconhecido: $1" >&2; exit 1 ;;
  esac
done

token_status="missing"
if [[ -n "${GITLAB_TOKEN:-}" ]]; then
  token_status="ok"
fi

hook_status="missing"
if [[ -f "${HOOK}" ]]; then
  hook_status="ok"
  if [[ ! -x "${HOOK}" ]]; then
    hook_status="ok_via_bash"
  fi
fi
hooks_json="${HOME}/.cursor/hooks.json"
if [[ -f "${hooks_json}" ]] && grep -q 'revisar-tarefa-prefetch-diff' "${hooks_json}" 2>/dev/null; then
  if ! grep -qE '\$HOME/\.cursor/hooks/revisar-tarefa-prefetch-diff' "${hooks_json}" 2>/dev/null; then
    hook_status="hooks_json_relative_path"
  fi
else
  [[ "${hook_status}" == "ok" || "${hook_status}" == "ok_via_bash" ]] && hook_status="hooks_json_missing_entry"
fi

cache_status="skipped"
if [[ -n "${BRANCH}" ]] && [[ -x "${CACHE_SCRIPT}" ]]; then
  set +e
  cache_out="$("${CACHE_SCRIPT}" --branch "${BRANCH}" ${TITULO:+--titulo "$TITULO"} 2>&1)"
  cache_ec=$?
  set -e
  if [[ "${cache_ec}" -eq 0 ]]; then
    cache_status="HIT"
  elif echo "${cache_out}" | grep -q 'CACHE_MISS'; then
    cache_status="MISS"
  else
    cache_status="error"
  fi
fi

api_status="skipped"
api_note=""
if [[ -f "${SCRIPT_DIR}/gitlab-api-env.sh" ]]; then
  # shellcheck source=gitlab-api-env.sh
  source "${SCRIPT_DIR}/gitlab-api-env.sh"
  set +e
  if gitlab_api_curl "${GITLAB_API_BASE}/version" >/dev/null 2>&1; then
    api_status="ok"
  elif gitlab_api_is_cursor_agent_shell 2>/dev/null; then
    api_status="agent_shell_blocked"
    api_note="esperado no agente; use cache do hook ou ctx_execute"
  else
    api_status="unreachable"
    api_note="VPN/rede ou GITLAB_TOKEN inválido"
  fi
  set -e
fi

echo "## GitLab ready"
echo ""
echo "| Check | Status | Detalhe |"
echo "|-------|--------|---------|"
echo "| GITLAB_TOKEN | ${token_status} | env |"
echo "| hook prefetch | ${hook_status} | ${HOOK} |"
echo "| cache diff | ${cache_status} | ${BRANCH:-—} |"
echo "| api (shell) | ${api_status} | ${api_note:-—} |"
echo ""

if [[ "${token_status}" == "missing" ]]; then
  echo "**Token:** export GITLAB_TOKEN=\"glpat-...\" (PAT em gitlab.baladapp.com.br)"
  echo ""
fi

if [[ "${cache_status}" == "MISS" ]]; then
  echo "**Cache:** hook roda ao enviar \`/revisar-tarefa <título>\` (VPN on). Ou:"
  echo "\`scripts/prefetch-diff.sh --titulo \"...\" --branch \"...\" --repo baladapp/...\`"
  echo ""
fi

if [[ "${cache_status}" == "HIT" ]]; then
  echo "**Agente:** usar cache (\`read-diff-bundle-cache.sh\`) — suficiente para montar \`## Diff\`."
elif [[ "${api_status}" == "agent_shell_blocked" ]]; then
  echo "**Agente:** cache miss → \`ctx_execute\` (fetch REST) ou \`prefetch-diff.sh\` no Terminal integrado."
elif [[ "${api_status}" == "ok" ]]; then
  echo "**Agente:** REST API acessível — rodar \`gitlab-api-phase3-diff-bundle.sh\`."
else
  echo "**Agente:** corrigir GITLAB_TOKEN/VPN ou rodar prefetch no Terminal integrado."
fi
