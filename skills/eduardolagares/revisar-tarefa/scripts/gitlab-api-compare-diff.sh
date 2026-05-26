#!/usr/bin/env bash
# Compare branch vs base via GitLab REST API (curl).
# Uso: gitlab-api-compare-diff.sh <namespace/project> <branch> [base_ref] [arquivo_saida]
set -euo pipefail

REPO="${1:?Uso: gitlab-api-compare-diff.sh namespace/project branch [base_ref] [outfile]}"
BRANCH="${2:?Uso: gitlab-api-compare-diff.sh namespace/project branch [base_ref] [outfile]}"
BASE="master"
OUT=""

if [[ $# -ge 4 ]]; then
  BASE="${3}"
  OUT="${4}"
elif [[ $# -eq 3 ]]; then
  if [[ "${3}" == *"/"* || "${3}" == *.diff ]]; then
    OUT="${3}"
  else
    BASE="${3}"
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=gitlab-api-env.sh
source "${SCRIPT_DIR}/gitlab-api-env.sh"

ENCODED="$(gitlab_api_urlencode "${REPO}")"
URL="${GITLAB_API_BASE}/projects/${ENCODED}/repository/compare?from=${BASE}&to=${BRANCH}"

set +e
json="$(gitlab_api_curl "${URL}" 2>&1)"
ec=$?
set -e

if [[ "${ec}" -ne 0 ]]; then
  [[ "${ec}" -eq 2 ]] && exit 2
  echo "FAIL: GET ${URL} (exit ${ec})" >&2
  echo "${json}" >&2
  exit 1
fi

diff_text="$(echo "${json}" | jq -r '
  .diffs // []
  | map(
      if .diff then
        "--- a/\(.old_path // .new_path)\n+++ b/\(.new_path // .old_path)\n\(.diff)"
      else empty end
    )
  | join("\n")
')"

if [[ -z "${diff_text}" ]]; then
  echo "WARN: compare sem hunks (branch inexistente ou igual à base?)" >&2
fi

if [[ -n "${OUT}" ]]; then
  printf '%s\n' "${diff_text}" > "${OUT}"
  echo "OK: api compare → ${OUT} (base=${BASE} to=${BRANCH})"
else
  printf '%s\n' "${diff_text}"
fi
