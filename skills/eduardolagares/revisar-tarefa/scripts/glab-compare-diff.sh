#!/usr/bin/env bash
# Diff branch vs base ref via GitLab compare API (sem MR).
# Uso: glab-compare-diff.sh <namespace/project> <branch> [base_ref] [arquivo_saida]
#   base_ref default: master
set -euo pipefail

REPO="${1:?Uso: glab-compare-diff.sh namespace/project branch [base_ref] [outfile]}"
BRANCH="${2:?Uso: glab-compare-diff.sh namespace/project branch [base_ref] [outfile]}"
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
# shellcheck source=glab-env.sh
source "${SCRIPT_DIR}/glab-env.sh"

urlencode() {
  python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
}

ENCODED="$(urlencode "${REPO}")"
ENDPOINT="projects/${ENCODED}/repository/compare?from=${BASE}&to=${BRANCH}"

set +e
json="$(glab_exec api "${ENDPOINT}" 2>&1)"
ec=$?
set -e

if [[ "${ec}" -ne 0 ]]; then
  if [[ "${ec}" -eq 2 ]]; then
    exit 2
  fi
  echo "FAIL: glab api ${ENDPOINT} (exit ${ec})" >&2
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
  echo "OK: compare diff salvo em ${OUT} (base=${BASE} to=${BRANCH})"
else
  printf '%s\n' "${diff_text}"
fi
