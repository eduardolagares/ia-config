#!/usr/bin/env bash
# Garante merge request aberto: source_branch → target_branch.
# Uso: gitlab-api-mr-ensure.sh <namespace/project> <source-branch> --target <branch> [--title <título>]
# Saída: uma linha JSON em stdout (última linha útil); diagnóstico em stderr.
set -euo pipefail

REPO="${1:?Uso: gitlab-api-mr-ensure.sh namespace/project source-branch --target master [--title T]}"
SOURCE="${2:?}"
shift 2

TARGET="${GITLAB_MR_TARGET:-${GLAB_DIFF_BASE:-master}}"
TITLE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:?}"
      shift 2
      ;;
    --title)
      TITLE="${2:?}"
      shift 2
      ;;
    *)
      echo "FAIL: argumento desconhecido: $1" >&2
      exit 1
      ;;
  esac
done

[[ -n "${TITLE}" ]] || TITLE="${SOURCE}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=gitlab-api-env.sh
source "${SCRIPT_DIR}/gitlab-api-env.sh"

command -v jq >/dev/null 2>&1 || {
  echo "FAIL: jq não instalado (brew install jq)" >&2
  exit 1
}

ENCODED="$(gitlab_api_urlencode "${REPO}")"
API="${GITLAB_API_BASE}/projects/${ENCODED}"

emit_json() {
  local action="$1"
  local iid="${2:-}"
  local web_url="${3:-}"
  local target_branch="$4"
  local err="${5:-}"
  local iid_json="null"
  [[ -n "${iid}" ]] && iid_json="${iid}"
  jq -nc \
    --arg repo "${REPO}" \
    --arg source "${SOURCE}" \
    --arg target "${target_branch}" \
    --arg action "${action}" \
    --arg url "${web_url}" \
    --arg err "${err}" \
    --argjson iid "${iid_json}" \
    '{
      repo: $repo,
      source_branch: $source,
      target_branch: $target,
      action: (if $action == "" then null else $action end),
      iid: $iid,
      web_url: (if $url == "" then null else $url end),
      error: (if $err == "" then null else $err end)
    }'
}

api() {
  local method="$1"
  local url="$2"
  local body="${3:-}"
  local out ec
  set +e
  if [[ -n "${body}" ]]; then
    out="$(gitlab_api_curl "${url}" -X "${method}" -d "${body}" 2>&1)"
  else
    out="$(gitlab_api_curl "${url}" -X "${method}" 2>&1)"
  fi
  ec=$?
  set -e
  printf '%s' "${out}"
  return "${ec}"
}

fail() {
  local msg="$1"
  emit_json "" "" "" "${TARGET}" "${msg}"
  exit 1
}

BRANCH_ENC="$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "${SOURCE}")"
LIST_URL="${API}/merge_requests?source_branch=${BRANCH_ENC}&state=opened&per_page=50"

set +e
list_raw="$(api GET "${LIST_URL}")"
list_ec=$?
set -e

if [[ "${list_ec}" -eq 2 ]]; then
  exit 2
fi
if [[ "${list_ec}" -ne 0 ]]; then
  fail "listar MRs falhou: ${list_raw}"
fi

mr="$(echo "${list_raw}" | jq -c --arg src "${SOURCE}" --arg tgt "${TARGET}" '
  [.[] | select(.source_branch == $src)]
  | if length == 0 then empty
    else (
      (map(select(.target_branch == $tgt)) | if length > 0 then .[0] else .[0] end)
    )
  end
')"

if [[ -n "${mr}" ]]; then
  mr_iid="$(echo "${mr}" | jq -r '.iid')"
  current_target="$(echo "${mr}" | jq -r '.target_branch')"
  web_url="$(echo "${mr}" | jq -r '.web_url')"
  current_title="$(echo "${mr}" | jq -r '.title // empty')"

  if [[ "${current_target}" != "${TARGET}" ]]; then
    body="$(jq -nc --arg tb "${TARGET}" --arg t "${TITLE}" '{target_branch: $tb, title: $t}')"
    set +e
    updated="$(api PUT "${API}/merge_requests/${mr_iid}" "${body}")"
    upd_ec=$?
    set -e
    [[ "${upd_ec}" -eq 2 ]] && exit 2
    if [[ "${upd_ec}" -ne 0 ]]; then
      fail "atualizar target do MR !${mr_iid} falhou: ${updated}"
    fi
    web_url="$(echo "${updated}" | jq -r '.web_url')"
    emit_json "updated_target" "${mr_iid}" "${web_url}" "${TARGET}" ""
    exit 0
  fi

  if [[ -n "${TITLE}" && "${current_title}" != "${TITLE}" ]]; then
    body="$(jq -nc --arg t "${TITLE}" '{title: $t}')"
    set +e
    updated="$(api PUT "${API}/merge_requests/${mr_iid}" "${body}")"
    upd_ec=$?
    set -e
    [[ "${upd_ec}" -eq 2 ]] && exit 2
    if [[ "${upd_ec}" -ne 0 ]]; then
      fail "atualizar título do MR !${mr_iid} falhou: ${updated}"
    fi
    web_url="$(echo "${updated}" | jq -r '.web_url // empty')"
    [[ -z "${web_url}" ]] && web_url="$(echo "${mr}" | jq -r '.web_url')"
  fi

  emit_json "existing" "${mr_iid}" "${web_url}" "${TARGET}" ""
  exit 0
fi

create_body="$(jq -nc \
  --arg sb "${SOURCE}" \
  --arg tb "${TARGET}" \
  --arg t "${TITLE}" \
  '{source_branch: $sb, target_branch: $tb, title: $t, remove_source_branch: false}')"

set +e
created="$(api POST "${API}/merge_requests" "${create_body}")"
create_ec=$?
set -e

if [[ "${create_ec}" -eq 2 ]]; then
  exit 2
fi

if [[ "${create_ec}" -ne 0 ]]; then
  # MR pode já existir (409) — re-listar
  if echo "${created}" | grep -qiE 'already exists|Another open merge request'; then
    set +e
    list_raw="$(api GET "${LIST_URL}")"
    list_ec=$?
    set -e
    if [[ "${list_ec}" -eq 0 ]]; then
      mr="$(echo "${list_raw}" | jq -c --arg src "${SOURCE}" '[.[] | select(.source_branch == $src)] | .[0] // empty')"
      if [[ -n "${mr}" ]]; then
        mr_iid="$(echo "${mr}" | jq -r '.iid')"
        web_url="$(echo "${mr}" | jq -r '.web_url')"
        current_target="$(echo "${mr}" | jq -r '.target_branch')"
        if [[ "${current_target}" == "${TARGET}" ]]; then
          emit_json "existing" "${mr_iid}" "${web_url}" "${TARGET}" ""
          exit 0
        fi
        body="$(jq -nc --arg tb "${TARGET}" --arg t "${TITLE}" '{target_branch: $tb, title: $t}')"
        set +e
        updated="$(api PUT "${API}/merge_requests/${mr_iid}" "${body}")"
        upd_ec=$?
        set -e
        [[ "${upd_ec}" -eq 2 ]] && exit 2
        if [[ "${upd_ec}" -eq 0 ]]; then
          web_url="$(echo "${updated}" | jq -r '.web_url')"
          emit_json "updated_target" "${mr_iid}" "${web_url}" "${TARGET}" ""
          exit 0
        fi
      fi
    fi
  fi
  fail "criar MR falhou: ${created}"
fi

mr_iid="$(echo "${created}" | jq -r '.iid')"
web_url="$(echo "${created}" | jq -r '.web_url')"
emit_json "created" "${mr_iid}" "${web_url}" "${TARGET}" ""
exit 0
