#!/usr/bin/env bash
# Resolve discussion no MR (re-run Pub1).
# Uso: glab-mr-discussion-resolve.sh <namespace/project> <iid> <discussion_id>
set -euo pipefail

REPO="${1:?Uso: glab-mr-discussion-resolve.sh namespace/project iid discussion_id}"
IID="${2:?}"
DISCUSSION_ID="${3:?}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=glab-env.sh
source "${SCRIPT_DIR}/glab-env.sh"

glab_exec mr note resolve "${DISCUSSION_ID}" "${IID}" -R "${REPO}" || {
  ec=$?
  [[ "$ec" -eq 2 ]] && exit 2
  echo "FAIL: glab mr note resolve ${DISCUSSION_ID} ${IID} -R ${REPO}" >&2
  exit 1
}

echo "OK: discussion ${DISCUSSION_ID} resolvida em ${REPO} !${IID}"
