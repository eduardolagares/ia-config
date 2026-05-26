#!/usr/bin/env bash
# Persiste no cache uma entrada já obtida via MCP Monday (passo 1).
# Uso: write-task-cache.sh "<título exato>" < payload.json
#   ou: write-task-cache.sh "<título exato>" --file payload.json
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_FILE="$(cd "${SCRIPT_DIR}/.." && pwd)/cache/tasks-by-title.json"

TITLE=""
PAYLOAD_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      PAYLOAD_FILE="${2:?}"
      shift 2
      ;;
    --help|-h)
      echo "Uso: write-task-cache.sh \"<título>\" < payload.json" >&2
      echo "     write-task-cache.sh \"<título>\" --file payload.json" >&2
      exit 0
      ;;
    *)
      TITLE="$1"
      shift
      ;;
  esac
done

[[ -n "${TITLE}" ]] || {
  echo "FAIL: título obrigatório" >&2
  exit 1
}

command -v jq >/dev/null || {
  echo "FAIL: jq não instalado" >&2
  exit 1
}

if [[ -n "${PAYLOAD_FILE}" ]]; then
  payload="$(cat "${PAYLOAD_FILE}")"
else
  payload="$(cat)"
fi

echo "${payload}" | jq -e . >/dev/null || {
  echo "FAIL: JSON inválido" >&2
  exit 1
}

mkdir -p "$(dirname "${CACHE_FILE}")"
if [[ -f "${CACHE_FILE}" ]]; then
  tmp="$(mktemp)"
  jq --arg title "${TITLE}" --argjson entry "${payload}" \
    '.[$title] = $entry' "${CACHE_FILE}" >"${tmp}"
  mv "${tmp}" "${CACHE_FILE}"
else
  jq -n --arg title "${TITLE}" --argjson entry "${payload}" \
    '{($title): $entry}' >"${CACHE_FILE}"
fi

echo "OK: cache atualizado em ${CACHE_FILE} (chave=${TITLE})"
