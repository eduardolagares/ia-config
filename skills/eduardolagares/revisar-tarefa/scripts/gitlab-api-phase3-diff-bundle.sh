#!/usr/bin/env bash
# Passo 3: diff via GitLab REST API (curl + token), sem binário glab.
# Uso: gitlab-api-phase3-diff-bundle.sh <source-branch> <repo1> [repo2 ...]
set -euo pipefail

BRANCH="${1:?Uso: gitlab-api-phase3-diff-bundle.sh source-branch repo [repo2...]}"
shift

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_REF="${GLAB_DIFF_BASE:-master}"
PREVIEW_LINES="${GLAB_DIFF_PREVIEW_LINES:-400}"
TMP_ROOT="${GLAB_DIFF_TMP:-/tmp/revisar-tarefa-diff}"

REPOS=("$@")
[[ ${#REPOS[@]} -gt 0 ]] || { echo "FAIL: nenhum repo informado" >&2; exit 1; }

mkdir -p "${TMP_ROOT}"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
run_dir="${TMP_ROOT}/${stamp}-$$-api"
mkdir -p "${run_dir}"

results=()
errors=()
need_terminal=0

for repo in "${REPOS[@]}"; do
  [[ -z "${repo}" ]] && continue
  slug="${repo//\//-}"
  diff_file="${run_dir}/${slug}.diff"
  method=""
  mr_iid=""
  mr_url=""
  target_branch=""
  diff_bytes=0
  err_msg=""

  set +e
  find_out="$("${SCRIPT_DIR}/gitlab-api-mr-find.sh" "${repo}" "${BRANCH}" 2>&1)"
  find_ec=$?
  set -e

  if [[ "${find_ec}" -eq 2 ]]; then
    need_terminal=1
    err_msg="GLAB_RUN_IN_USER_TERMINAL"
    errors+=("${repo}: ${err_msg}")
    results+=("$(jq -n --arg repo "${repo}" --arg branch "${BRANCH}" --arg base "${BASE_REF}" --arg err "${err_msg}" \
      '{repo: $repo, source_branch: $branch, base_ref: $base, method: null, mr_iid: null, mr_url: null, target_branch: null, diff_file: null, diff_bytes: 0, diff_truncated: false, error: $err}')")
    continue
  fi

  find_json="$(echo "${find_out}" | tail -1)"
  count="$(echo "${find_json}" | jq -r '.count // 0')"

  if [[ "${find_ec}" -eq 0 ]] && [[ "${count}" -gt 0 ]]; then
    mr_iid="$(echo "${find_json}" | jq -r '.mrs[0].iid')"
    mr_url="$(echo "${find_json}" | jq -r '.mrs[0].web_url')"
    target_branch="$(echo "${find_json}" | jq -r '.mrs[0].target_branch // empty')"
    set +e
    if "${SCRIPT_DIR}/gitlab-api-mr-diff.sh" "${repo}" "${mr_iid}" "${diff_file}" >/dev/null 2>&1; then
      method="api_mr_diff"
    else
      mr_diff_ec=$?
      if [[ "${mr_diff_ec}" -eq 2 ]]; then
        need_terminal=1
        err_msg="GLAB_RUN_IN_USER_TERMINAL"
      else
        err_msg="api mr diff falhou (iid=${mr_iid})"
      fi
    fi
    set -e
  fi

  if [[ -z "${method}" && -z "${err_msg}" ]]; then
    set +e
    if "${SCRIPT_DIR}/gitlab-api-compare-diff.sh" "${repo}" "${BRANCH}" "${BASE_REF}" "${diff_file}" >/dev/null 2>&1; then
      method="api_compare"
      target_branch="${BASE_REF}"
    else
      cmp_ec=$?
      if [[ "${cmp_ec}" -eq 2 ]]; then
        need_terminal=1
        err_msg="GLAB_RUN_IN_USER_TERMINAL"
      elif [[ "${find_ec}" -eq 3 ]]; then
        err_msg="sem MR na branch e api compare falhou"
      else
        err_msg="api compare ${BASE_REF}...${BRANCH} falhou"
      fi
    fi
    set -e
  fi

  if [[ -f "${diff_file}" ]]; then
    diff_bytes="$(wc -c < "${diff_file}" | tr -d ' ')"
  else
    diff_file=""
  fi

  truncated=false
  if [[ -f "${diff_file}" ]] && [[ "${diff_bytes}" -gt 0 ]]; then
    line_count="$(wc -l < "${diff_file}" | tr -d ' ')"
    if [[ "${line_count}" -gt "${PREVIEW_LINES}" ]]; then
      truncated=true
      preview_file="${diff_file%.diff}.preview.diff"
      head -n "${PREVIEW_LINES}" "${diff_file}" > "${preview_file}"
    fi
  fi

  [[ -n "${err_msg}" ]] && errors+=("${repo}: ${err_msg}")

  results+=("$(jq -n \
    --arg repo "${repo}" \
    --arg branch "${BRANCH}" \
    --arg base "${BASE_REF}" \
    --arg method "${method}" \
    --arg mr_iid "${mr_iid}" \
    --arg mr_url "${mr_url}" \
    --arg target "${target_branch}" \
    --arg diff_file "${diff_file}" \
    --argjson diff_bytes "${diff_bytes:-0}" \
    --argjson truncated "${truncated}" \
    --arg err "${err_msg}" \
    '{
      repo: $repo, source_branch: $branch, base_ref: $base,
      method: (if $method == "" then null else $method end),
      mr_iid: (if $mr_iid == "" then null else ($mr_iid | tonumber) end),
      mr_url: (if $mr_url == "" then null else $mr_url end),
      target_branch: (if $target == "" then null else $target end),
      diff_file: (if $diff_file == "" then null else $diff_file end),
      diff_bytes: $diff_bytes, diff_truncated: $truncated,
      error: (if $err == "" then null else $err end)
    }')")
done

jq -n \
  --arg branch "${BRANCH}" \
  --arg base "${BASE_REF}" \
  --arg run_dir "${run_dir}" \
  --arg fetch_backend "api" \
  --argjson projects "$(printf '%s\n' "${results[@]}" | jq -s '.')" \
  --argjson errors "$(printf '%s\n' "${errors[@]:-}" | jq -R -s 'split("\n") | map(select(length>0))')" \
  '{source_branch: $branch, base_ref: $base, run_dir: $run_dir, fetch_backend: $fetch_backend, projects: $projects, errors: $errors}'

if [[ "${need_terminal}" -eq 1 ]]; then
  echo "GLAB_RUN_IN_USER_TERMINAL=1" >&2
  echo "Rode no seu Terminal (com VPN ativa):" >&2
  echo "  REVISAR_TAREFA_DIFF_FETCH=api ${SCRIPT_DIR}/gitlab-api-phase3-diff-bundle.sh $(printf '%q ' "${BRANCH}" "${REPOS[@]}")" >&2
  exit 2
fi

if [[ "${#errors[@]}" -gt 0 ]] && [[ "$(printf '%s\n' "${results[@]}" | jq -s '[.[] | select(.diff_file != null)] | length')" -eq 0 ]]; then
  exit 1
fi
