#!/usr/bin/env bash
# GitLab REST API — env partilhado (GITLAB_TOKEN, curl helpers).

for _gitlab_env_file in "${HOME}/.zshenv" "${HOME}/.zshrc"; do
  if [[ -f "${_gitlab_env_file}" ]]; then
    set +e
    set +u
    # shellcheck disable=SC1090
    source "${_gitlab_env_file}" 2>/dev/null
    set -e
    set -u
  fi
  if [[ -n "${GITLAB_TOKEN:-}" ]]; then
    break
  fi
done
unset _gitlab_env_file

set -euo pipefail

GITLAB_API_BASE="${GITLAB_API_BASE:-https://gitlab.baladapp.com.br/api/v4}"

gitlab_api_urlencode() {
  python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
}

gitlab_api_is_cursor_agent_shell() {
  [[ -n "${CURSOR_AGENT:-}" || -n "${CURSOR_TRACE_ID:-}" ]]
}

gitlab_api_curl() {
  local url="$1"
  shift || true
  if [[ -z "${GITLAB_TOKEN:-}" ]]; then
    echo "FAIL: GITLAB_TOKEN ausente" >&2
    return 1
  fi
  local ec=0
  local out
  set +e
  out="$(curl -sS --fail-with-body \
    -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    -H "Content-Type: application/json" \
    "$@" \
    "${url}" 2>&1)"
  ec=$?
  set -e
  if [[ "${ec}" -ne 0 ]]; then
    if gitlab_api_is_cursor_agent_shell; then
      return 2
    fi
    echo "${out}" >&2
    return 1
  fi
  printf '%s' "${out}"
}
