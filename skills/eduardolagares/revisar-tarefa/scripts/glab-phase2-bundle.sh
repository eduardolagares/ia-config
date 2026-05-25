#!/usr/bin/env bash
# Fase 2 em lote: um JSON com MR por projeto confirmado.
# Uso: glab-phase2-bundle.sh <source-branch> <repo1> [repo2 ...]
#   ou: glab-phase2-bundle.sh <source-branch> < repos.txt
set -euo pipefail

BRANCH="${1:?Uso: glab-phase2-bundle.sh source-branch repo [repo2...]}"
shift

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ $# -eq 0 ]]; then
  REPOS=()
  while IFS= read -r line; do
    [[ -n "${line}" ]] && REPOS+=("${line}")
  done
else
  REPOS=("$@")
fi

[[ ${#REPOS[@]} -gt 0 ]] || { echo "FAIL: nenhum repo informado" >&2; exit 1; }

results=()
errors=()
need_terminal=0

for repo in "${REPOS[@]}"; do
  [[ -z "${repo}" ]] && continue
  out="$( "${SCRIPT_DIR}/glab-mr-find.sh" "${repo}" "${BRANCH}" 2>&1)" || ec=$?
  ec=${ec:-0}
  if [[ "${ec}" -eq 2 ]]; then
    need_terminal=1
    errors+=("${repo}: GLAB_RUN_IN_USER_TERMINAL")
  elif [[ "${ec}" -eq 3 ]]; then
    results+=("$(echo "${out}" | tail -1 | jq -c . 2>/dev/null || echo "{\"repo\":\"${repo}\",\"count\":0,\"mrs\":[]}")")
  elif [[ "${ec}" -ne 0 ]]; then
    errors+=("${repo}: ${out}")
  else
    results+=("${out}")
  fi
done

jq -n \
  --arg branch "${BRANCH}" \
  --argjson projects "$(printf '%s\n' "${results[@]}" | jq -s '.')" \
  --argjson errors "$(printf '%s\n' "${errors[@]:-}" | jq -R -s 'split("\n") | map(select(length>0))')" \
  '{source_branch: $branch, projects: $projects, errors: $errors}'

if [[ "${need_terminal}" -eq 1 ]]; then
  echo "GLAB_RUN_IN_USER_TERMINAL=1" >&2
  echo "Rode no seu Terminal:" >&2
  echo "  ${SCRIPT_DIR}/glab-phase2-bundle.sh $(printf '%q ' "${BRANCH}" "${REPOS[@]}")" >&2
  exit 2
fi
