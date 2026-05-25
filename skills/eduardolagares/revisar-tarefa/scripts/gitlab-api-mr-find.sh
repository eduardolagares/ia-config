#!/usr/bin/env bash
# Lista MRs por source_branch via REST API.
# Uso: gitlab-api-mr-find.sh <namespace/project> <source-branch>
set -euo pipefail

REPO="${1:?}"
BRANCH="${2:?}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=gitlab-api-env.sh
source "${SCRIPT_DIR}/gitlab-api-env.sh"

ENCODED="$(gitlab_api_urlencode "${REPO}")"
BRANCH_ENC="$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "${BRANCH}")"
URL="${GITLAB_API_BASE}/projects/${ENCODED}/merge_requests?source_branch=${BRANCH_ENC}&state=opened&per_page=20"

set +e
json="$(gitlab_api_curl "${URL}" 2>&1)"
ec=$?
set -e

if [[ "${ec}" -ne 0 ]]; then
  [[ "${ec}" -eq 2 ]] && exit 2
  echo "FAIL: GET ${URL}" >&2
  exit 1
fi

count="$(echo "${json}" | jq 'length')"
echo "${json}" | jq -c --arg repo "${REPO}" --arg branch "${BRANCH}" \
  '{repo: $repo, source_branch: $branch, count: (. | length), mrs: [.[] | {iid, title, web_url, state, source_branch, target_branch}]}'

[[ "${count}" -eq 0 ]] && exit 3
exit 0
