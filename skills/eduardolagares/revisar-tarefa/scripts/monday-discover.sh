#!/usr/bin/env bash
# Discovery Monday — board Dia a Dia (revisar-tarefa)
# Lista colunas (id, título, tipo), labels de Status, gera ~/.config/revisar-tarefa/monday.env
#
# Uso:
#   export MONDAY_API_TOKEN="..."
#   ./monday-discover.sh
#
# Opcional:
#   MONDAY_BOARD_ID=4571892384
#   MONDAY_TEST_TITLE="título exato"   # testa busca de item
#   MONDAY_JSON_OUT=1                  # grava monday-board.json (default: 1)

set -euo pipefail

BOARD_ID="${MONDAY_BOARD_ID:-4571892384}"
BOARD_URL="https://baladapp-company.monday.com/boards/${BOARD_ID}"

if [[ ! "$BOARD_ID" =~ ^[0-9]+$ ]]; then
  echo "Erro: MONDAY_BOARD_ID deve ser numérico (recebido: $BOARD_ID)" >&2
  exit 1
fi
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/revisar-tarefa"
OUT_ENV="$CONFIG_DIR/monday.env"
OUT_JSON="$CONFIG_DIR/monday-board.json"
OUT_STATUS_LABELS="$CONFIG_DIR/monday-status-labels.json"
WRITE_JSON="${MONDAY_JSON_OUT:-1}"

# Colunas exigidas pela skill /revisar-tarefa (título exato no board)
REQUIRED_TITLES=(Branch Status)
# Status labels usados em Mon2 (+ referência)
STATUS_LABELS_WANTED=(QA Fazendo "Aguardando deploy")
# Tipos úteis para extrair projetos (texto livre) — sem mirror
DOC_TYPES_RE='^(file|doc|long_text|text|link)$'
# Coluna status gravável no Mon2 (board Dia a dia: não usar mirror "Status")
MONDAY_STATUS_COLUMN_TITLE="${MONDAY_STATUS_COLUMN_TITLE:-Status consolidado}"
# Subtarefas: board filho (type sub_items_board) — coluna Status gravável
MONDAY_SUBITEM_STATUS_COLUMN_TITLE="${MONDAY_SUBITEM_STATUS_COLUMN_TITLE:-Status}"
SUBITEM_STATUS_LABELS_WANTED=(Testar "Aguardando revisão de código" QA Fazendo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JQ_STATUS_LABELS="${SCRIPT_DIR}/monday-status-labels.jq"
OUT_SUBITEM_STATUS_LABELS="${CONFIG_DIR}/monday-subitem-status-labels.json"

if [[ -z "${MONDAY_API_TOKEN:-}" ]]; then
  echo "Erro: export MONDAY_API_TOKEN antes de rodar." >&2
  echo "  Token: Monday → Developers → My access tokens" >&2
  exit 1
fi

for cmd in jq curl; do
  command -v "$cmd" >/dev/null || { echo "Instale: brew install $cmd" >&2; exit 1; }
done

mkdir -p "$CONFIG_DIR"

gql() {
  local query="$1"
  local variables="${2:-}"
  local payload
  if [[ -n "$variables" ]]; then
    payload="$(jq -n --arg q "$query" --arg v "$variables" '{query: $q, variables: ($v | fromjson)}')" \
      || { echo "Erro: JSON de variables inválido: $variables" >&2; return 1; }
  else
    payload="$(jq -n --arg q "$query" '{query: $q}')"
  fi
  local http body
  body="$(curl -sS -w "\n%{http_code}" -X POST https://api.monday.com/v2 \
    -H "Authorization: $MONDAY_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload")" || { echo "Erro: curl não conectou à api.monday.com" >&2; return 1; }
  http="${body##*$'\n'}"
  body="${body%$'\n'*}"
  if [[ "$http" != "200" ]]; then
    echo "Erro: API Monday HTTP $http" >&2
    echo "$body" | jq . 2>/dev/null || echo "$body" >&2
    return 1
  fi
  echo "$body"
}

gql_vars() {
  jq -n "$@"
}

section() { echo ""; echo "════════════════════════════════════════════════════════"; echo " $1"; echo "════════════════════════════════════════════════════════"; }

# --- 1. Token ---
section "1. Token"
me="$(gql 'query { me { id name email } }')"
if echo "$me" | jq -e '.errors[0]' >/dev/null 2>&1; then
  echo "$me" | jq '.errors' >&2
  exit 1
fi
echo "$me" | jq -r '.data.me | "OK  usuário: \(.name)  id=\(.id)"'

# --- 2. Board + colunas ---
section "2. Board"
# ID embutido na query (evita bug de --argjson com array)
# settings é JSON escalar (sem subcampos GraphQL) — usar settings + settings_str
board_q="query {
  boards(ids: [${BOARD_ID}]) {
    id
    name
    description
    columns {
      id
      title
      type
      archived
      settings_str
      settings
    }
  }
}"
board_json="$(gql "$board_q")"

if echo "$board_json" | jq -e '.errors[0]' >/dev/null 2>&1; then
  echo "$board_json" | jq '.errors' >&2
  exit 1
fi

board_id="$(echo "$board_json" | jq -r '.data.boards[0].id // empty')"
board_name="$(echo "$board_json" | jq -r '.data.boards[0].name // empty')"

if [[ -z "$board_id" || "$board_id" == "null" ]]; then
  echo "Board id=${BOARD_ID} não encontrado ou sem permissão." >&2
  exit 1
fi

echo "Board:  $board_name"
echo "ID:     $board_id"
echo "URL:    $BOARD_URL"

section "3. Todas as colunas (id | tipo | título)"
printf "%-28s %-18s %s\n" "COLUMN_ID" "TYPE" "TITLE"
printf "%-28s %-18s %s\n" "----------" "----" "-----"
echo "$board_json" | jq -r '
  .data.boards[0].columns[]
  | select(.archived != true)
  | "\(.id)\t\(.type)\t\(.title)"
' | while IFS=$'\t' read -r cid ctype ctitle; do
  mark=""
  [[ "$ctitle" == "Branch" ]] && mark="  ← skill (branch)"
  [[ "$ctitle" == "$MONDAY_STATUS_COLUMN_TITLE" ]] && mark="  ← skill (status Mon2)"
  [[ "$ctitle" == "Status" && "$ctype" == "mirror" ]] && mark="  ← mirror (só leitura)"
  printf "%-28s %-18s %s%s\n" "$cid" "$ctype" "$ctitle" "$mark"
done

# --- 4. Colunas obrigatórias ---
section "4. Colunas da skill /revisar-tarefa"

col_name_id="name"
col_branch="$(echo "$board_json" | jq -r '.data.boards[0].columns[] | select(.title=="Branch") | .id' | head -1)"
col_status_mirror="$(echo "$board_json" | jq -r '.data.boards[0].columns[] | select(.title=="Status" and .type=="mirror") | .id' | head -1)"
col_status="$(echo "$board_json" | jq -r --arg t "$MONDAY_STATUS_COLUMN_TITLE" '
  .data.boards[0].columns[] | select(.title == $t and .type == "status") | .id' | head -1)"

echo "Item título (fixo API):     column_id = name"
echo "Branch (coluna texto):      column_id = ${col_branch:-⚠ NÃO ENCONTRADA}"
echo "Status Mon2 (gravável):     column_id = ${col_status:-⚠ NÃO ENCONTRADA}  (título: $MONDAY_STATUS_COLUMN_TITLE)"
if [[ -n "${col_status_mirror:-}" ]]; then
  echo "Status mirror (só leitura): column_id = $col_status_mirror  — não usar em change_column_value"
fi

section "5. Colunas de documento / texto (projetos em texto livre)"
doc_cols="$(echo "$board_json" | jq -r --arg re "$DOC_TYPES_RE" --arg st "$MONDAY_STATUS_COLUMN_TITLE" '
  .data.boards[0].columns[]
  | select(.archived != true)
  | select(.title != "Branch" and .title != "Status" and .title != $st)
  | select(.type | test($re))
  | "\(.id)\t\(.type)\t\(.title)"
')"
if [[ -n "$doc_cols" ]]; then
  printf "%-28s %-18s %s\n" "COLUMN_ID" "TYPE" "TITLE"
  echo "$doc_cols" | while IFS=$'\t' read -r cid ctype ctitle; do
    printf "%-28s %-18s %s\n" "$cid" "$ctype" "$ctitle"
  done
  col_docs="$(echo "$doc_cols" | cut -f1 | paste -sd, -)"
else
  echo "(nenhuma coluna extra file/doc/text detectada — projetos só em updates/descrição)"
  col_docs=""
fi

# --- 6. Labels status — item principal (board Dia a dia) ---
section "6. Item principal — colunas status (labels)"

status_labels_json="$(echo "$board_json" | jq '.data.boards[0].columns' | jq -f "$JQ_STATUS_LABELS")"

status_col_count="$(echo "$status_labels_json" | jq 'length')"
if [[ "$status_col_count" == "0" ]]; then
  echo "⚠ Nenhuma coluna type=status no board."
else
  echo "Colunas status encontradas: $status_col_count"
  echo ""

  echo "$status_labels_json" | jq -r '.[] | "-- \(.column_title) (id=\(.column_id), \(.labels | length) labels)"'
  echo ""

  # Tabela por coluna
  echo "$status_labels_json" | jq -c '.[]' | while read -r col_block; do
    ctitle="$(echo "$col_block" | jq -r '.column_title')"
    cid="$(echo "$col_block" | jq -r '.column_id')"
    echo ""
    echo "▸ $ctitle  ($cid)"
    printf "  %-6s %-6s %-22s %-12s %-6s %s\n" "INDEX" "ID" "LABEL" "COLOR" "DONE" "SRC"
    echo "$col_block" | jq -r '.labels[]? |
      "\(.index)\t\(.id // "-")\t\(.label)\t\(.color // "-")\t\(.is_done)\t\(.source)"' \
      | while IFS=$'\t' read -r idx lid label color is_done src; do
        note=""
        if [[ "$cid" == "${col_status:-}" ]]; then
          for want in "${STATUS_LABELS_WANTED[@]}"; do
            [[ "$label" == "$want" ]] && note="  ← Mon2"
          done
        fi
        printf "  %-6s %-6s %-22s %-12s %-6s %s%s\n" "$idx" "$lid" "$label" "$color" "$is_done" "$src" "$note"
      done
  done
fi

# Salvar JSON de labels (todas colunas status)
echo "$status_labels_json" | jq '.' > "$OUT_STATUS_LABELS"
chmod 600 "$OUT_STATUS_LABELS"
echo ""
echo "→ $OUT_STATUS_LABELS"

# IDs de label na coluna Mon2 (Monday usa id no JSON {"index": N})
idx_qa=""
idx_fazendo=""
idx_deploy=""
if [[ -z "${col_status:-}" || "$col_status" == "null" ]]; then
  # auto-detect: coluna status com labels QA + Fazendo
  col_status="$(echo "$status_labels_json" | jq -r '
    .[] | select(.labels | map(.label) | contains(["QA"]) and contains(["Fazendo"])) | .column_id' | head -1)"
  [[ -n "$col_status" ]] && echo "→ Status Mon2 auto-detectado: $col_status"
fi

if [[ -n "${col_status:-}" && "$col_status" != "null" ]]; then
  main_labels="$(echo "$status_labels_json" | jq --arg cid "$col_status" '.[] | select(.column_id == $cid) | .labels')"
  idx_qa="$(echo "$main_labels" | jq -r '.[] | select(.label == "QA") | .id' | head -1)"
  idx_fazendo="$(echo "$main_labels" | jq -r '.[] | select(.label == "Fazendo") | .id' | head -1)"
  idx_deploy="$(echo "$main_labels" | jq -r '.[] | select(.label == "Aguardando deploy") | .id' | head -1)"
fi

echo ""
echo "Mon2 — coluna $MONDAY_STATUS_COLUMN_TITLE ($col_status):"
echo "  mutation index = id do label (change_column_value value: {\"index\": N} ou change_simple_column_value label)"
echo "  QA:                label=\"QA\"                id=${idx_qa:-?}"
echo "  Fazendo:           label=\"Fazendo\"           id=${idx_fazendo:-?}"
echo "  Aguardando deploy: label=\"Aguardando deploy\" id=${idx_deploy:-?}"

# --- 7. Subtarefas — board filho + Status ---
section "7. Subtarefas — board e coluna Status"

subitem_board_json=""
subitem_board_id=""
subitem_board_name=""
col_subitem_status=""
subitem_status_labels_json="[]"
idx_sub_testar=""
idx_sub_rev=""

if [[ -n "${MONDAY_SUBITEM_BOARD_ID:-}" ]]; then
  subitem_probe="$(gql "query { boards(ids: [${MONDAY_SUBITEM_BOARD_ID}]) { id name type columns { id title type archived settings settings_str } } }")"
  subitem_board_json="$(echo "$subitem_probe" | jq '.data.boards[0]')"
  echo "→ Board subtarefas via MONDAY_SUBITEM_BOARD_ID=${MONDAY_SUBITEM_BOARD_ID}"
else
  subitem_probe_q="query {
    boards(ids: [${BOARD_ID}]) {
      items_page(limit: 40) {
        items {
          id name
          subitems {
            id name
            board {
              id name type
              columns { id title type archived settings settings_str }
            }
          }
        }
      }
    }
  }"
  subitem_probe="$(gql "$subitem_probe_q")"
  subitem_board_json="$(echo "$subitem_probe" | jq '
    [.data.boards[0].items_page.items[].subitems[]?.board?]
    | unique_by(.id) | .[0] // empty
  ')"
  if [[ -z "$(echo "$subitem_board_json" | jq -r '.id // empty')" ]]; then
    echo "⚠ Nenhuma subtarefa encontrada nos últimos 40 itens do board."
    echo "  Dica: export MONDAY_SUBITEM_BOARD_ID=<id> ou garanta um item com subitems."
  else
    echo "→ Board subtarefas inferido do primeiro subitem com board"
  fi
fi

if [[ -n "$(echo "$subitem_board_json" | jq -r '.id // empty' 2>/dev/null)" ]]; then
  subitem_board_id="$(echo "$subitem_board_json" | jq -r '.id')"
  subitem_board_name="$(echo "$subitem_board_json" | jq -r '.name')"
  subitem_board_type="$(echo "$subitem_board_json" | jq -r '.type // "?"')"
  echo "Board subtarefas: $subitem_board_name"
  echo "  id:   $subitem_board_id"
  echo "  type: $subitem_board_type"

  subitem_status_labels_json="$(echo "$subitem_board_json" | jq '.columns' | jq -f "$JQ_STATUS_LABELS")"
  col_subitem_status="$(echo "$subitem_board_json" | jq -r --arg t "$MONDAY_SUBITEM_STATUS_COLUMN_TITLE" '
    .columns[] | select(.title == $t and .type == "status") | .id' | head -1)"

  if [[ -z "${col_subitem_status:-}" ]]; then
    col_subitem_status="$(echo "$subitem_status_labels_json" | jq -r --arg t "$MONDAY_SUBITEM_STATUS_COLUMN_TITLE" '
      .[] | select(.column_title == $t) | .column_id' | head -1)"
  fi

  echo "Status subtarefa (Mon2/exec): column_id = ${col_subitem_status:-⚠ NÃO ENCONTRADA}  (título: $MONDAY_SUBITEM_STATUS_COLUMN_TITLE)"
  echo ""

  subitem_count="$(echo "$subitem_status_labels_json" | jq 'length')"
  echo "Colunas status no board subtarefas: $subitem_count"
  echo "$subitem_status_labels_json" | jq -c '.[]' | while read -r col_block; do
    ctitle="$(echo "$col_block" | jq -r '.column_title')"
    cid="$(echo "$col_block" | jq -r '.column_id')"
    echo ""
    echo "▸ [subitem] $ctitle  ($cid)"
    printf "  %-6s %-6s %-22s %-12s %-6s %s\n" "INDEX" "ID" "LABEL" "COLOR" "DONE" "SRC"
    echo "$col_block" | jq -r '.labels[]? |
      "\(.index)\t\(.id // "-")\t\(.label)\t\(.color // "-")\t\(.is_done)\t\(.source)"' \
      | while IFS=$'\t' read -r idx lid label color is_done src; do
        note=""
        if [[ "$cid" == "${col_subitem_status:-}" ]]; then
          for want in "${SUBITEM_STATUS_LABELS_WANTED[@]}"; do
            [[ "$label" == "$want" ]] && note="  ← subtarefa"
          done
        fi
        printf "  %-6s %-6s %-22s %-12s %-6s %s%s\n" "$idx" "$lid" "$label" "$color" "$is_done" "$src" "$note"
      done
  done

  echo "$subitem_status_labels_json" | jq --arg bid "$subitem_board_id" --arg bname "$subitem_board_name" \
    '{board_id: $bid, board_name: $bname, status_columns: .}' > "$OUT_SUBITEM_STATUS_LABELS"
  chmod 600 "$OUT_SUBITEM_STATUS_LABELS"
  echo ""
  echo "→ $OUT_SUBITEM_STATUS_LABELS"

  if [[ -n "${col_subitem_status:-}" ]]; then
    sub_labels="$(echo "$subitem_status_labels_json" | jq --arg cid "$col_subitem_status" '.[] | select(.column_id == $cid) | .labels')"
    idx_sub_testar="$(echo "$sub_labels" | jq -r '.[] | select(.label == "Testar") | .id' | head -1)"
    idx_sub_rev="$(echo "$sub_labels" | jq -r '.[] | select(.label == "Aguardando revisão de código") | .id' | head -1)"
    echo ""
    echo "Subtarefa — coluna $MONDAY_SUBITEM_STATUS_COLUMN_TITLE ($col_subitem_status):"
    echo "  Testar:                        id=${idx_sub_testar:-?}"
    echo "  Aguardando revisão de código: id=${idx_sub_rev:-?}"
  fi
fi

# --- 8. Teste de item (opcional) ---
if [[ -n "${MONDAY_TEST_TITLE:-}" ]]; then
  section "8. Teste item: \"$MONDAY_TEST_TITLE\""
  item_q='query ($boardId: ID!, $title: String!) {
    items_page_by_column_values(
      board_id: $boardId
      columns: [{ column_id: "name", column_values: [$title] }]
    ) {
      items {
        id name url
        column_values { id text value column { title type } }
      }
    }
  }'
  item_vars="$(gql_vars --arg bid "$board_id" --arg t "$MONDAY_TEST_TITLE" '{boardId: $bid, title: $t}')"
  item_json="$(gql "$item_q" "$item_vars")"
  count="$(echo "$item_json" | jq '.data.items_page_by_column_values.items | length')"
  echo "Itens encontrados: $count"
  echo "$item_json" | jq -r '.data.items_page_by_column_values.items[] |
    "  id=\(.id)  url=\(.url)"'
  echo "$item_json" | jq -r '.data.items_page_by_column_values.items[0].column_values[]? |
    select(.column.title == "Branch" or .column.title == "Status") |
    "  \(.column.title): \(.text // .value // "-")"'
fi

# --- 9. Gerar monday.env ---
section "9. Arquivos gerados"

{
  echo "# Gerado por monday-discover.sh — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# Board: $board_name — $BOARD_URL"
  echo ""
  echo "export MONDAY_BOARD_ID=\"$board_id\""
  echo "export MONDAY_COL_NAME=\"name\""
  [[ -n "${col_branch:-}" ]] && echo "export MONDAY_COL_BRANCH=\"$col_branch\""
  [[ -n "${col_status:-}" ]] && echo "export MONDAY_COL_STATUS=\"$col_status\""
  echo "export MONDAY_COL_STATUS_TITLE=\"$MONDAY_STATUS_COLUMN_TITLE\""
  [[ -n "${col_status_mirror:-}" ]] && echo "export MONDAY_COL_STATUS_MIRROR=\"$col_status_mirror\""
  [[ -n "${col_docs:-}" ]] && echo "export MONDAY_COL_DOCS=\"$col_docs\""
  echo ""
  echo "# Labels Status consolidado — preferir change_simple_column_value com LABEL"
  echo "export MONDAY_STATUS_LABEL_QA=\"QA\""
  echo "export MONDAY_STATUS_LABEL_FAZENDO=\"Fazendo\""
  echo "export MONDAY_STATUS_LABEL_DEPLOY=\"Aguardando deploy\""
  [[ -n "${idx_qa:-}" ]] && echo "export MONDAY_STATUS_INDEX_QA=\"$idx_qa\""
  [[ -n "${idx_fazendo:-}" ]] && echo "export MONDAY_STATUS_INDEX_FAZENDO=\"$idx_fazendo\""
  [[ -n "${idx_deploy:-}" ]] && echo "export MONDAY_STATUS_INDEX_DEPLOY=\"$idx_deploy\""
  echo "export MONDAY_STATUS_LABELS_FILE=\"$OUT_STATUS_LABELS\""
  echo ""
  echo "# Subtarefas (board filho)"
  [[ -n "${subitem_board_id:-}" ]] && echo "export MONDAY_SUBITEM_BOARD_ID=\"$subitem_board_id\""
  [[ -n "${col_subitem_status:-}" ]] && echo "export MONDAY_COL_SUBITEM_STATUS=\"$col_subitem_status\""
  echo "export MONDAY_COL_SUBITEM_STATUS_TITLE=\"$MONDAY_SUBITEM_STATUS_COLUMN_TITLE\""
  [[ -n "${idx_sub_testar:-}" ]] && echo "export MONDAY_SUBITEM_STATUS_INDEX_TESTAR=\"$idx_sub_testar\""
  [[ -n "${idx_sub_rev:-}" ]] && echo "export MONDAY_SUBITEM_STATUS_INDEX_REVISAO=\"$idx_sub_rev\""
  echo "export MONDAY_SUBITEM_STATUS_LABELS_FILE=\"$OUT_SUBITEM_STATUS_LABELS\""
} > "$OUT_ENV"
chmod 600 "$OUT_ENV"
echo "→ $OUT_ENV"

if [[ "$WRITE_JSON" == "1" ]]; then
  echo "$board_json" | jq --arg url "$BOARD_URL" --arg re "$DOC_TYPES_RE" --arg st "$MONDAY_STATUS_COLUMN_TITLE" \
    --argjson status_cols "$status_labels_json" --argjson sub_cols "$subitem_status_labels_json" \
    --arg sub_bid "${subitem_board_id:-}" --arg sub_bname "${subitem_board_name:-}" '
    .data.boards[0] as $b |
    {
      board: { id: $b.id, name: $b.name, url: $url },
      required: {
        name: "name",
        branch: ($b.columns[] | select(.title == "Branch") | .id),
        status: ($b.columns[] | select(.title == $st and .type == "status") | .id)
      },
      document_columns: [
        $b.columns[]
        | select(.archived != true)
        | select(.title != "Branch" and .title != "Status" and .title != $st)
        | select(.type | test($re))
        | { id, title, type }
      ],
      status_columns: $status_cols,
      subitems_board: (if $sub_bid != "" then { id: $sub_bid, name: $sub_bname, status_columns: $sub_cols } else null end),
      columns: [
        $b.columns[] | select(.archived != true) | { id, title, type }
      ]
    }
  ' > "$OUT_JSON"
  chmod 600 "$OUT_JSON"
  echo "→ $OUT_JSON"
fi

echo ""
echo "Adicione ao ~/.zshrc:"
echo "  source \"$OUT_ENV\""

missing=0
[[ -z "${col_branch:-}" ]] && { echo "⚠ Falta coluna Branch no board." >&2; missing=1; }
[[ -z "${col_status:-}" ]] && { echo "⚠ Falta coluna Status no board." >&2; missing=1; }
[[ -z "${idx_qa:-}" || -z "${idx_fazendo:-}" ]] && echo "⚠ Labels QA/Fazendo (item principal) não mapeados." >&2
if [[ -n "${subitem_board_id:-}" && -z "${col_subitem_status:-}" ]]; then
  echo "⚠ Coluna Status das subtarefas não mapeada (ver seção 7)." >&2
  missing=1
fi
exit "$missing"
