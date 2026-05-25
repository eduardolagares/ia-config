#!/usr/bin/env bash
# Valida env + ficheiros para /revisar-tarefa
set -uo pipefail

source "${HOME}/.config/revisar-tarefa/monday.env" 2>/dev/null || true
# Token costuma estar no ~/.zshrc
[[ -f "${HOME}/.zshrc" ]] && source "${HOME}/.zshrc" 2>/dev/null || true

ok=0
fail=0

check() {
  local name="$1"
  local val="${2:-}"
  if [[ -n "$val" ]]; then
    echo "  OK   $name=${val}"
    ok=$((ok + 1))
  else
    echo "  FAIL $name (vazio)"
    fail=$((fail + 1))
  fi
}

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

echo "════════════════════════════════════════════════════════"
echo " /revisar-tarefa — validação de ambiente"
echo "════════════════════════════════════════════════════════"

echo ""
echo "── Monday (token + board)"
check_secret MONDAY_API_TOKEN "${MONDAY_API_TOKEN:-}"
check MONDAY_BOARD_ID "${MONDAY_BOARD_ID:-}"
check MONDAY_COL_BRANCH "${MONDAY_COL_BRANCH:-}"
check MONDAY_COL_STATUS "${MONDAY_COL_STATUS:-}"
check MONDAY_COL_STATUS_TITLE "${MONDAY_COL_STATUS_TITLE:-}"
check MONDAY_COL_STATUS_MIRROR "${MONDAY_COL_STATUS_MIRROR:-}"
check MONDAY_STATUS_INDEX_QA "${MONDAY_STATUS_INDEX_QA:-}"
check MONDAY_STATUS_INDEX_FAZENDO "${MONDAY_STATUS_INDEX_FAZENDO:-}"

echo ""
echo "── Monday (subtarefas)"
check MONDAY_SUBITEM_BOARD_ID "${MONDAY_SUBITEM_BOARD_ID:-}"
check MONDAY_COL_SUBITEM_STATUS "${MONDAY_COL_SUBITEM_STATUS:-}"
check MONDAY_SUBITEM_STATUS_INDEX_TESTAR "${MONDAY_SUBITEM_STATUS_INDEX_TESTAR:-}"
check MONDAY_SUBITEM_STATUS_INDEX_REVISAO "${MONDAY_SUBITEM_STATUS_INDEX_REVISAO:-}"

echo ""
echo "── Monday (ficheiros JSON)"
check_file "${MONDAY_STATUS_LABELS_FILE:-$HOME/.config/revisar-tarefa/monday-status-labels.json}"
check_file "${MONDAY_SUBITEM_STATUS_LABELS_FILE:-$HOME/.config/revisar-tarefa/monday-subitem-status-labels.json}"

echo ""
echo "── GitLab (glab — terminal do usuário)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if out="$("${SCRIPT_DIR}/glab-validate.sh" 2>&1)"; then
  echo "${out}" | sed 's/^/  OK   /'
  ok=$((ok + 2))
else
  echo "${out}" | sed 's/^/  FAIL /'
  fail=$((fail + 1))
fi

echo ""
echo "── Resumo esperado (Dia a dia)"
echo "  Branch coluna:     texto"
echo "  Status pai:        status_1 (Status consolidado) — NÃO espelho"
echo "  Status subtarefa:  ${MONDAY_COL_SUBITEM_STATUS:-?} no board ${MONDAY_SUBITEM_BOARD_ID:-?}"

echo ""
echo "════════════════════════════════════════════════════════"
echo " OK=$ok  FAIL=$fail"
[[ "$fail" -eq 0 ]] && echo " Tudo pronto para /revisar-tarefa" || echo " Corrija FAIL e rode monday-discover.sh de novo"
echo "════════════════════════════════════════════════════════"
exit "$fail"
