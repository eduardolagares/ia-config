#!/usr/bin/env bash
# Garante MR (source → master) para cada repo da tarefa.
# Uso: gitlab-api-mr-ensure-bundle.sh --branch <branch> [--titulo "título"] <repo1> [repo2...]
set -euo pipefail

BRANCH=""
TITULO=""
REPOS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      BRANCH="${2:?}"
      shift 2
      ;;
    --titulo|--title)
      TITULO="${2:?}"
      shift 2
      ;;
    --)
      shift
      REPOS+=("$@")
      break
      ;;
    -*)
      echo "FAIL: flag desconhecida: $1" >&2
      exit 1
      ;;
    *)
      REPOS+=("$1")
      shift
      ;;
  esac
done

[[ -n "${BRANCH}" ]] || { echo "FAIL: --branch obrigatório" >&2; exit 1; }
[[ ${#REPOS[@]} -gt 0 ]] || { echo "FAIL: informe ao menos um namespace/project" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${GLAB_DIFF_BASE:-master}"
MR_TITLE="${TITULO:-${BRANCH}}"

results=()
errors=()
need_terminal=0

for repo in "${REPOS[@]}"; do
  [[ -z "${repo}" ]] && continue
  set +e
  out="$("${SCRIPT_DIR}/gitlab-api-mr-ensure.sh" "${repo}" "${BRANCH}" --target "${TARGET}" --title "${MR_TITLE}" 2>&1)"
  ec=$?
  set -e

  if [[ "${ec}" -eq 2 ]]; then
    need_terminal=1
    errors+=("${repo}: GLAB_RUN_IN_USER_TERMINAL")
    results+=("$(jq -n --arg repo "${repo}" --arg branch "${BRANCH}" --arg target "${TARGET}" \
      '{repo: $repo, source_branch: $branch, target_branch: $target, action: null, iid: null, web_url: null, error: "GLAB_RUN_IN_USER_TERMINAL"}')")
    continue
  fi

  if [[ "${ec}" -ne 0 ]]; then
    err_line="$(echo "${out}" | tail -1)"
    errors+=("${repo}: ${err_line}")
    results+=("$(jq -n --arg repo "${repo}" --arg branch "${BRANCH}" --arg target "${TARGET}" --arg err "${err_line}" \
      '{repo: $repo, source_branch: $branch, target_branch: $target, action: null, iid: null, web_url: null, error: $err}')")
    continue
  fi

  line="$(echo "${out}" | tail -1)"
  results+=("${line}")
done

projects_json="$(printf '%s\n' "${results[@]}" | jq -s '.')"
if [[ ${#errors[@]} -eq 0 ]]; then
  errors_json='[]'
else
  errors_json="$(printf '%s\n' "${errors[@]}" | jq -R . | jq -s '.')"
fi

jq -n \
  --arg branch "${BRANCH}" \
  --arg target "${TARGET}" \
  --arg title "${MR_TITLE}" \
  --argjson projects "${projects_json}" \
  --argjson errors "${errors_json}" \
  --argjson need_terminal "${need_terminal}" \
  '{branch: $branch, target_branch: $target, mr_title: $title, projects: $projects, errors: $errors, need_terminal: ($need_terminal == 1)}'

[[ "${need_terminal}" -eq 1 ]] && exit 2
[[ "$(echo "${errors_json}" | jq 'length')" -gt 0 ]] && [[ "$(echo "${projects_json}" | jq '[.[] | select(.web_url != null)] | length')" -eq 0 ]] && exit 1
exit 0
