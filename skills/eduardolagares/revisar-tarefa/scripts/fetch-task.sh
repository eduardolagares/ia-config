#!/usr/bin/env bash
# Busca tarefa no Monday (board Dia a dia) por título exato.
# Uso:
#   fetch-task.sh "Título exato"
#   fetch-task.sh --json "Título exato"
#   fetch-task.sh --check
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=monday-lib.sh
source "${SCRIPT_DIR}/monday-lib.sh"

OUTPUT_JSON=0
TITLE=""

usage() {
  echo "Uso: fetch-task.sh [--json] \"Título exato da tarefa\"" >&2
  echo "     fetch-task.sh --check" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json|-j) OUTPUT_JSON=1; shift ;;
    --check|-c)
      load_monday_env
      echo "→ Token (me)..."
      monday_gql "$(jq -n '{query: "query { me { id name } }"}')" \
        | jq -r '.data.me | "OK  \(.name) (\(.id))"'
      echo "→ Board Dia a dia..."
      monday_gql "$(jq -n --argjson bid "[${MONDAY_BOARD_ID}]" \
        '{query: "query($id:[ID!]){boards(ids:$id){id name}}", variables:{id:$bid}}')" \
        | jq -r '.data.boards[0] | "OK  \(.name) (\(.id))"'
      echo "Ambiente OK para fetch-task."
      exit 0
      ;;
    --help|-h) usage ;;
    *)
      TITLE="$1"
      shift
      ;;
  esac
done

[[ -n "${TITLE}" ]] || usage
load_monday_env

COL_BRANCH="${MONDAY_COL_BRANCH:-texto}"
COL_STATUS="${MONDAY_COL_STATUS:-status_1}"
COL_SUB_STATUS="${MONDAY_COL_SUBITEM_STATUS:-status}"
COL_DOCS="${MONDAY_COL_DOCS:-monday_doc}"

query='query ($boardId: ID!, $title: String!) {
  items_page_by_column_values(
    board_id: $boardId
    columns: [{ column_id: "name", column_values: [$title] }]
  ) {
    items {
      id
      name
      url
      description {
        text
        html
      }
      group { id title }
      column_values {
        id
        text
        value
        column { id title type }
      }
      updates(limit: 50) {
        id
        body
        text_body
        created_at
      }
      subitems {
        id
        name
        url
        column_values {
          id
          text
          value
          column { id title type }
        }
      }
    }
  }
}'

payload="$(jq -n --arg bid "${MONDAY_BOARD_ID}" --arg title "${TITLE}" --arg q "${query}" \
  '{query: $q, variables: {boardId: $bid, title: $title}}')"

resp="$(monday_gql "${payload}")"

count="$(echo "${resp}" | jq '.data.items_page_by_column_values.items | length')"

if [[ "${count}" == "0" ]]; then
  echo "FAIL: nenhum item com título exato:" >&2
  echo "  ${TITLE}" >&2
  exit 1
fi

if [[ "${count}" != "1" ]]; then
  echo "FAIL: ${count} itens com mesmo título (ambíguo):" >&2
  echo "${resp}" | jq -r '.data.items_page_by_column_values.items[] | "  id=\(.id)  \(.url)"' >&2
  exit 2
fi

item="$(echo "${resp}" | jq -c '.data.items_page_by_column_values.items[0]')"

branch="$(echo "${item}" | jq -r --arg br "${COL_BRANCH}" \
  '.column_values[] | select(.column.id==$br) | .text // empty' | head -1)"
status="$(echo "${item}" | jq -r --arg st "${COL_STATUS}" \
  '.column_values[] | select(.column.id==$st) | .text // empty' | head -1)"
status_mirror="$(echo "${item}" | jq -r --arg mir "${MONDAY_COL_STATUS_MIRROR:-espelho}" \
  '.column_values[] | select(.column.id==$mir) | .text // empty' | head -1)"

text_blob="$(echo "${item}" | jq -r --arg docs "${COL_DOCS}" '
  [
    (.description.text // ""),
    (.updates[]? | .text_body // .body // ""),
    (.column_values[]? | select(.column.id as $id | ($docs | split(",") | index($id)) != null) | .text // .value // ""),
    (.column_values[]? | .text // .value // "")
  ] | join("\n")
')"

projects="$(infer_gitlab_projects "${text_blob}")"

if [[ "${OUTPUT_JSON}" -eq 1 ]]; then
  projects_json="$(printf '%s\n' "${projects}" | jq -R -s 'split("\n") | map(select(length > 0))')"
  jq -n \
    --argjson item "${item}" \
    --arg branch "${branch}" \
    --arg status "${status}" \
    --arg status_mirror "${status_mirror}" \
    --arg text_blob "${text_blob}" \
    --argjson projects "${projects_json}" \
    '{
      item: $item,
      branch: $branch,
      status_consolidado: $status,
      status_mirror: $status_mirror,
      projects_inferred: $projects,
      context_text: $text_blob
    }'
  exit 0
fi

echo "════════════════════════════════════════════════════════"
echo " Tarefa: $(echo "${item}" | jq -r '.name')"
echo "════════════════════════════════════════════════════════"
echo "id:    $(echo "${item}" | jq -r '.id')"
echo "url:   $(echo "${item}" | jq -r '.url')"
echo "grupo: $(echo "${item}" | jq -r '.group.title // "-"')"

echo ""
echo "── Colunas principais"
echo "${item}" | jq -r --arg br "${COL_BRANCH}" --arg st "${COL_STATUS}" --arg mir "${MONDAY_COL_STATUS_MIRROR:-espelho}" '
  .column_values[]
  | select(.column.id == $br or .column.id == $st or .column.id == $mir or .column.title == "Documento")
  | "  \(.column.title) (\(.column.id)): \(.text // .value // "-")"
'

echo ""
echo "── Branch (GitLab): ${branch:-⚠ vazio}"
echo "── Status consolidado: ${status:-⚠ vazio}"
[[ -n "${status_mirror}" ]] && echo "── Status (mirror/espelho): ${status_mirror}"

if [[ -n "$(echo "${item}" | jq -r '.description.text // empty')" ]]; then
  echo ""
  echo "── Descrição (trecho)"
  echo "${item}" | jq -r '.description.text' | head -20
fi

echo ""
echo "── Atualizações (projetos / contexto)"
echo "${item}" | jq -r '.updates[]? | "[\(.created_at)] \(.text_body // .body // "" | gsub("<[^>]+>"; "") | .[0:200])"'

echo ""
echo "── Subtarefas ($(echo "${item}" | jq '.subitems | length'))"
echo "${item}" | jq -r --arg st "${COL_SUB_STATUS}" '
  .subitems[]?
  | . as $s
  | ($s.column_values[] | select(.column.id==$st) | .text) as $status
  | "  • \(.name)  id=\(.id)  status=\($status // "-")  \(.url)"
'

echo ""
echo "── Projetos inferidos (confirmar antes do glab — C1)"
if [[ -n "${projects}" ]]; then
  echo "${projects}" | sed 's/^/  /'
else
  echo "  (nenhum — confira Documento/atualizações ou rode fetch-task-doc.sh)"
fi

echo ""
echo "── JSON (--json para agente)"
echo "  ${SCRIPT_DIR}/fetch-task.sh --json $(printf '%q' "${TITLE}")"

echo ""
echo "── Documento completo (opcional)"
echo "  ${SCRIPT_DIR}/fetch-task-doc.sh $(printf '%q' "${TITLE}")"
