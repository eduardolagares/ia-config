#!/usr/bin/env bash
# Lista discussions/notas do MR (para reconciliar [bld:N.M]).
# Uso: glab-mr-notes-list.sh <namespace/project> <iid>
set -euo pipefail

REPO="${1:?Uso: glab-mr-notes-list.sh namespace/project iid}"
IID="${2:?Uso: glab-mr-notes-list.sh namespace/project iid}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=glab-env.sh
source "${SCRIPT_DIR}/glab-env.sh"

set +e
json="$(glab_exec mr note list "${IID}" -R "${REPO}" -F json)"
ec=$?
set -e

if [[ "$ec" -ne 0 ]]; then
  [[ "$ec" -eq 2 ]] && exit 2
  echo "FAIL: glab mr note list ${IID} -R ${REPO} (exit ${ec})" >&2
  exit 1
fi

echo "${json}" | jq -c --arg repo "${REPO}" --argjson iid "${IID}" \
  '[.[] | {
    repo: $repo,
    mr_iid: $iid,
    discussion_id: (.id // .discussion_id // null),
    note_id: (.notes[0].id // .id // null),
    body: (.notes[0].body // .body // ""),
    resolved: (.resolved // .notes[0].resolved // false)
  }] | map(select(.body | test("\\[bld:[0-9]+\\.[0-9]+\\]")))'
