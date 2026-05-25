#!/usr/bin/env bash
# Diff de MR via GET .../merge_requests/:iid/changes
# Uso: gitlab-api-mr-diff.sh <namespace/project> <iid> [arquivo_saida]
set -euo pipefail

REPO="${1:?}"
IID="${2:?}"
OUT="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=gitlab-api-env.sh
source "${SCRIPT_DIR}/gitlab-api-env.sh"

ENCODED="$(gitlab_api_urlencode "${REPO}")"
URL="${GITLAB_API_BASE}/projects/${ENCODED}/merge_requests/${IID}/changes"

set +e
json="$(gitlab_api_curl "${URL}" 2>&1)"
ec=$?
set -e

if [[ "${ec}" -ne 0 ]]; then
  [[ "${ec}" -eq 2 ]] && exit 2
  echo "FAIL: GET ${URL}" >&2
  exit 1
fi

diff_text="$(echo "${json}" | jq -r '
  .changes // []
  | map(
      if .diff then
        "--- a/\(.old_path // .new_path)\n+++ b/\(.new_path // .new_path)\n\(.diff)"
      else empty end
    )
  | join("\n")
')"

if [[ -n "${OUT}" ]]; then
  printf '%s\n' "${diff_text}" > "${OUT}"
  echo "OK: api mr diff → ${OUT}"
else
  printf '%s\n' "${diff_text}"
fi
