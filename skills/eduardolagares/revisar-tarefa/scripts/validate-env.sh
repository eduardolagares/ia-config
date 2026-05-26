#!/usr/bin/env bash
# Valida ambiente para /revisar-tarefa (GitLab REST + cache Monday).
set -uo pipefail

[[ -f "${HOME}/.zshrc" ]] && source "${HOME}/.zshrc" 2>/dev/null || true

ok=0
fail=0

check_secret() {
  local name="$1"
  local val="${2:-}"
  if [[ -n "$val" ]]; then
    echo "  OK   $name=*** (${#val} chars)"
    ok=$((ok + 1))
  else
    echo "  FAIL $name (vazio)"
    fail=$((fail + 1))
  fi
}

check_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    echo "  OK   file $path"
    ok=$((ok + 1))
  else
    echo "  FAIL file $path (ausente)"
    fail=$((fail + 1))
  fi
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

resolve_monday_cache() {
  local candidate
  for candidate in \
    "${SKILL_ROOT}/../monday-task-info/cache/tasks-by-title.json" \
    "${HOME}/.agents/skills/eduardolagares/monday-task-info/cache/tasks-by-title.json" \
    "${HOME}/.cursor/skills/eduardolagares/monday-task-info/cache/tasks-by-title.json"; do
    if [[ -f "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return 0
    fi
  done
  return 1
}

echo "════════════════════════════════════════════════════════"
echo " /revisar-tarefa — validação de ambiente"
echo "════════════════════════════════════════════════════════"

echo ""
echo "── Monday (MCP Cursor — não há token/script neste repo)"
echo "  O agente usa CallMcpTool → server: plugin-monday.com-monday"
echo "  Utilizador: Cursor → Settings → MCP → Monday (ligado)"
MONDAY_CACHE=""
if MONDAY_CACHE="$(resolve_monday_cache)"; then
  check_file "${MONDAY_CACHE}"
else
  echo "  INFO cache tasks-by-title.json ausente (normal antes do passo 1 /monday-task-info)"
fi

echo ""
echo "── GitLab (REST API — GITLAB_TOKEN)"
check_secret GITLAB_TOKEN "${GITLAB_TOKEN:-}"
if out="$("${SCRIPT_DIR}/gitlab-api-validate.sh" 2>&1)"; then
  echo "${out}" | sed 's/^/  OK   /'
  ok=$((ok + 1))
else
  echo "${out}" | sed 's/^/  FAIL /'
  fail=$((fail + 1))
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo " OK=$ok  FAIL=$fail"
[[ "$fail" -eq 0 ]] && echo " GitLab OK. Monday: confirmar MCP no Cursor." || echo " Corrija FAIL (GitLab)."
echo "════════════════════════════════════════════════════════"
exit "$fail"
