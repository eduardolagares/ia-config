#!/usr/bin/env bash
# Busca MR(s) por repo + source branch. Saída: JSON no stdout.
# Uso: glab-mr-find.sh <namespace/project> <source-branch>
set -euo pipefail

REPO="${1:?Uso: glab-mr-find.sh namespace/project source-branch}"
BRANCH="${2:?Uso: glab-mr-find.sh namespace/project source-branch}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=glab-env.sh
source "${SCRIPT_DIR}/glab-env.sh"

set +e
json="$(glab_exec mr list -R "${REPO}" --source-branch "${BRANCH}" -F json)"
ec=$?
set -e

if [[ "$ec" -ne 0 ]]; then
  if [[ "$ec" -eq 2 ]]; then
    exit 2
  fi
  echo "FAIL: glab mr list -R ${REPO} --source-branch ${BRANCH} (exit ${ec})" >&2
  exit 1
fi

count="$(echo "${json}" | jq 'length')"
echo "${json}" | jq -c --arg repo "${REPO}" --arg branch "${BRANCH}" \
  '{repo: $repo, source_branch: $branch, count: (. | length), mrs: [.[] | {iid, title, web_url, state, source_branch, target_branch}]}'

if [[ "${count}" -eq 0 ]]; then
  exit 3
fi
