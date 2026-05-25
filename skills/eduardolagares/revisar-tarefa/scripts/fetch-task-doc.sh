#!/usr/bin/env bash
# Lê coluna Documento (monday_doc) + conteúdo via API docs.
# Uso:
#   ./fetch-task-doc.sh --check              # valida token + API
#   ./fetch-task-doc.sh "Título exato"
set -euo pipefail

SCRIPT_NAME="${0##*/}"
DOC_COL="${MONDAY_DOC_COLUMN_ID:-monday_doc}"
BLOCKS_LIMIT="${MONDAY_DOC_BLOCKS_LIMIT:-250}"

usage() {
  echo "Uso: $SCRIPT_NAME --check | $SCRIPT_NAME \"Título exato da tarefa\"" >&2
  exit 1
}

load_env() {
  source "${HOME}/.config/revisar-tarefa/monday.env"
  if [[ -f "${HOME}/.zshrc" ]]; then
    # shellcheck disable=SC1090
    source "${HOME}/.zshrc" 2>/dev/null || true
  fi
  [[ -n "${MONDAY_API_TOKEN:-}" ]] || {
    echo "FAIL: MONDAY_API_TOKEN vazio (export no ~/.zshrc)" >&2
    exit 1
  }
  command -v jq >/dev/null || { echo "FAIL: instale jq (brew install jq)" >&2; exit 1; }
  command -v curl >/dev/null || { echo "FAIL: curl não encontrado" >&2; exit 1; }
}

gql() {
  local payload="$1"
  local body http
  body="$(curl -sS -w "\n%{http_code}" -X POST https://api.monday.com/v2 \
    -H "Authorization: ${MONDAY_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$payload")" || {
    echo "FAIL: curl não conectou em api.monday.com" >&2
    exit 1
  }
  http="${body##*$'\n'}"
  body="${body%$'\n'*}"
  if [[ "$http" != "200" ]]; then
    echo "FAIL: Monday API HTTP $http" >&2
    echo "$body" | jq . 2>/dev/null || echo "$body" >&2
    exit 1
  fi
  if echo "$body" | jq -e '.errors[0]' >/dev/null 2>&1; then
    echo "FAIL: GraphQL errors" >&2
    echo "$body" | jq '.errors' >&2
    exit 1
  fi
  echo "$body"
}

# Extrai texto legível de blocks (deltaFormat Monday doc)
blocks_to_text() {
  jq -r '
    def delta_text($c):
      if ($c | type) == "object" and ($c.deltaFormat? | type) == "array" then
        [$c.deltaFormat[]?
          | if (.insert | type) == "string" then .insert
            elif (.insert.text?) then .insert.text
            else empty end
        ] | join("")
      else empty end;
    def block_line:
      (.type // "block") as $t |
      (delta_text(.content) // empty) as $txt |
      if ($txt | length) > 0 then "[\($t)] \($txt)" else empty end;
    [.[] | block_line] | map(select(. != null and length > 0)) | join("\n")
  '
}

run_check() {
  echo "→ Testando token (me)..."
  gql "$(jq -n '{query: "query { me { id name } }"}')" | jq -r '.data.me | "OK  \(.name) (\(.id))"'

  echo "→ Testando boards:read (board Dia a dia)..."
  gql "$(jq -n --argjson bid "[${MONDAY_BOARD_ID}]" \
    '{query: "query($id:[ID!]){boards(ids:$id){id name}}", variables:{id:$bid}}')" \
    | jq -r '.data.boards[0] | "OK  board \(.name) (\(.id))"'

  echo "→ Testando docs:read (query vazia object_ids=0 — pode retornar [])..."
  docs_test="$(gql "$(jq -n \
    '{query: "query { docs(limit: 1) { id } }"}')" 2>&1)" || {
    echo "FAIL: scope docs:read ausente no token. Adicione docs:read no Monday → Developers → token." >&2
    exit 1
  }
  echo "$docs_test" | jq -r '"OK  docs API respondeu (\(.data.docs | length) doc(s) na amostra)"'

  echo ""
  echo "Ambiente OK para fetch-task-doc."
}

parse_doc_ids_from_value() {
  local value_raw="$1"
  local item_id="$2"
  # value pode ser string JSON ou objeto; extrai fileId / objectId
  echo "$value_raw" | jq -r --arg iid "$item_id" '
    (if type == "string" then (try fromjson catch {}) else . end) as $v |
    [
      $v.fileId?,
      $v.objectId?,
      ($v.files[]? | .fileId?),
      ($v.files[]? | .objectId?),
      $iid
    ] | map(select(. != null and (. | tostring) != "")) | unique | .[]
  ' 2>/dev/null || echo "$item_id"
}

fetch_item() {
  local title="$1"
  local q='query ($boardId: ID!, $title: String!, $docCol: String!) {
    items_page_by_column_values(
      board_id: $boardId
      columns: [{ column_id: "name", column_values: [$title] }]
    ) {
      items {
        id
        name
        url
        column_values(ids: [$docCol]) {
          id
          type
          text
          value
          column { id title type }
        }
      }
    }
  }'
  local payload
  payload="$(jq -n --arg bid "$MONDAY_BOARD_ID" --arg title "$title" --arg doc "$DOC_COL" --arg q "$q" \
    '{query: $q, variables: {boardId: $bid, title: $title, docCol: $doc}}')"
  gql "$payload"
}

fetch_docs() {
  local -a ids=("$@")
  local ids_json
  ids_json="$(printf '%s\n' "${ids[@]}" | jq -R . | jq -s .)"
  local q='query ($objectIds: [ID!], $limit: Int!) {
    docs(object_ids: $objectIds, limit: $limit) {
      id
      object_id
      name
      url
      relative_url
      blocks(limit: $limit) {
        id
        type
        content
      }
    }
  }'
  local payload
  payload="$(jq -n --argjson oids "$ids_json" --argjson lim "$BLOCKS_LIMIT" --arg q "$q" \
    '{query: $q, variables: {objectIds: $oids, limit: $lim}}')"
  gql "$payload"
}

fetch_docs_by_internal_id() {
  local doc_id="$1"
  local q='query ($ids: [ID!], $limit: Int!) {
    docs(ids: $ids, limit: 1) {
      id
      object_id
      name
      url
      blocks(limit: $limit) {
        id
        type
        content
      }
    }
  }'
  local payload
  payload="$(jq -n --argjson ids "[\"$doc_id\"]" --argjson lim "$BLOCKS_LIMIT" --arg q "$q" \
    '{query: $q, variables: {ids: $ids, limit: $lim}}')"
  gql "$payload"
}

run_fetch() {
  local title="$1"
  local resp item item_id item_name item_url cv value_raw
  local -a doc_ids=()

  echo "→ Buscando tarefa (título exato)..."
  resp="$(fetch_item "$title")"

  local count
  count="$(echo "$resp" | jq '.data.items_page_by_column_values.items | length')"
  if [[ "$count" == "0" ]]; then
    echo "FAIL: nenhum item com título:" >&2
    echo "  $title" >&2
    exit 1
  fi
  if [[ "$count" != "1" ]]; then
    echo "FAIL: $count itens com mesmo título (ambíguo):" >&2
    echo "$resp" | jq -r '.data.items_page_by_column_values.items[] | "  id=\(.id)  \(.url)"' >&2
    exit 2
  fi

  item="$(echo "$resp" | jq '.data.items_page_by_column_values.items[0]')"
  item_id="$(echo "$item" | jq -r '.id')"
  item_name="$(echo "$item" | jq -r '.name')"
  item_url="$(echo "$item" | jq -r '.url')"

  cv="$(echo "$item" | jq --arg col "$DOC_COL" '.column_values[] | select(.column.id == $col)')"
  if [[ -z "$(echo "$cv" | jq -r '.id // empty')" ]]; then
    echo "FAIL: coluna $DOC_COL não encontrada no item" >&2
    echo "$item" | jq -r '.column_values[] | "  \(.column.title) (\(.column.id))"' >&2
    exit 1
  fi

  value_raw="$(echo "$cv" | jq -r '.value // empty')"
  mapfile -t doc_ids < <(parse_doc_ids_from_value "$value_raw" "$item_id")

  echo "════════════════════════════════════════════════════════"
  echo " Documento — $item_name"
  echo "════════════════════════════════════════════════════════"
  echo "item_id:     $item_id"
  echo "url:       $item_url"
  echo "coluna:    $DOC_COL ($(echo "$cv" | jq -r '.column.title'))"
  echo ""
  echo "── column_values (resumo)"
  echo "$cv" | jq '{column: .column.title, type: .type, text: .text, value: (try (.value | if type==\"string\" then fromjson else . end) catch .value)}'

  echo ""
  echo "── IDs para API docs: ${doc_ids[*]}"

  if [[ "${MONDAY_DEBUG:-}" == "1" ]]; then
    mkdir -p /tmp/revisar-tarefa
    echo "$item" | jq . > "/tmp/revisar-tarefa/item-${item_id}.json"
    echo "DEBUG: /tmp/revisar-tarefa/item-${item_id}.json"
  fi

  echo ""
  echo "→ Buscando docs (object_ids)..."
  local docs_resp doc_count
  docs_resp="$(fetch_docs "${doc_ids[@]}")"
  doc_count="$(echo "$docs_resp" | jq '.data.docs | length')"

  # fallback: tentar fileId como docs(ids:)
  if [[ "$doc_count" == "0" ]]; then
    local file_id
    file_id="$(echo "$cv" | jq -r '(try (.value|if type=="string" then fromjson else . end) catch {}) | .files[0].fileId // .fileId // empty')"
    if [[ -n "$file_id" && "$file_id" != "null" ]]; then
      echo "→ Fallback docs(ids:) com fileId=$file_id ..."
      docs_resp="$(fetch_docs_by_internal_id "$file_id")"
      doc_count="$(echo "$docs_resp" | jq '.data.docs | length')"
    fi
  fi

  if [[ "$doc_count" == "0" ]]; then
    echo ""
    echo "WARN: nenhum doc retornado pela API."
    echo "  Abra o documento pelo item: $item_url"
    echo "  Confira scope docs:read no token."
    echo ""
    echo "── value bruto (para debug)"
    echo "$cv" | jq '.value'
    exit 0
  fi

  echo "$docs_resp" | jq -r '.data.docs[] | "OK  doc_id=\(.id)  object_id=\(.object_id)  name=\(.name // "-")"'
  echo "$docs_resp" | jq -r '.data.docs[] | "     url: \(.url // .relative_url // "-")"'

  if [[ "${MONDAY_DEBUG:-}" == "1" ]]; then
    echo "$docs_resp" | jq . > "/tmp/revisar-tarefa/docs-${item_id}.json"
    echo "DEBUG: /tmp/revisar-tarefa/docs-${item_id}.json"
  fi

  echo ""
  echo "── Conteúdo (texto extraído dos blocks)"
  local text
  text="$(echo "$docs_resp" | jq '[.data.docs[].blocks[]?]' | blocks_to_text)"
  if [[ -n "$text" ]]; then
    echo "$text"
  else
    echo "(sem texto em deltaFormat — veja MONDAY_DEBUG=1 ou abra a url do doc)"
    echo "$docs_resp" | jq -r '.data.docs[].blocks[]? | "[\(.type)] id=\(.id)"' | head -20
  fi

  echo ""
  echo "── Fim"
}

# --- main ---
[[ $# -ge 1 ]] || usage
load_env

case "${1:-}" in
  --check|-c)
    run_check
    ;;
  --help|-h)
    usage
    ;;
  *)
    run_fetch "$1"
    ;;
esac
