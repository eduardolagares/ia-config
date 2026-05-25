#!/usr/bin/env bash
# Funções compartilhadas — scripts Monday da skill /revisar-tarefa.
# Uso: source "$(dirname "$0")/monday-lib.sh"

load_monday_env() {
  local env_file="${HOME}/.config/revisar-tarefa/monday.env"
  [[ -f "${env_file}" ]] || {
    echo "FAIL: ${env_file} ausente — rode scripts/monday-discover.sh" >&2
    exit 1
  }
  # shellcheck disable=SC1090
  source "${env_file}"

  if [[ -f "${HOME}/.zshrc" ]]; then
    set +e
    set +u
    # shellcheck disable=SC1090
    source "${HOME}/.zshrc" 2>/dev/null
    set -e
    set -u
  fi

  [[ -n "${MONDAY_API_TOKEN:-}" ]] || {
    echo "FAIL: MONDAY_API_TOKEN vazio (export no ~/.zshrc)" >&2
    exit 1
  }
  command -v jq >/dev/null || { echo "FAIL: instale jq (brew install jq)" >&2; exit 1; }
  command -v curl >/dev/null || { echo "FAIL: curl não encontrado" >&2; exit 1; }
  [[ -n "${MONDAY_BOARD_ID:-}" ]] || {
    echo "FAIL: MONDAY_BOARD_ID vazio em monday.env" >&2
    exit 1
  }
}

monday_gql() {
  local payload="$1"
  local body http
  body="$(curl -sS -w "\n%{http_code}" -X POST https://api.monday.com/v2 \
    -H "Authorization: ${MONDAY_API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${payload}")" || {
    echo "FAIL: curl não conectou em api.monday.com" >&2
    exit 1
  }
  http="${body##*$'\n'}"
  body="${body%$'\n'*}"
  if [[ "${http}" != "200" ]]; then
    echo "FAIL: Monday API HTTP ${http}" >&2
    echo "${body}" | jq . 2>/dev/null || echo "${body}" >&2
    exit 1
  fi
  if echo "${body}" | jq -e '.errors[0]' >/dev/null 2>&1; then
    echo "FAIL: GraphQL errors" >&2
    echo "${body}" | jq '.errors' >&2
    exit 1
  fi
  echo "${body}"
}

# stdin: texto livre → stdout: um path por linha (namespace/project)
infer_gitlab_projects() {
  local text="$1"
  {
    echo "${text}" | grep -oE 'gitlab\.baladapp\.com\.br/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' \
      | sed 's|gitlab\.baladapp\.com\.br/||' || true
    echo "${text}" | grep -oiE 'baladapp/[a-z0-9_.-]+' || true
  } | sort -u
}
