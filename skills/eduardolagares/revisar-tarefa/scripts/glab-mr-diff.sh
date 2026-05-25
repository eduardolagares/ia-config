#!/usr/bin/env bash
# Diff do MR. Uso: glab-mr-diff.sh <namespace/project> <iid> [arquivo_saida]
set -euo pipefail

REPO="${1:?Uso: glab-mr-diff.sh namespace/project iid [outfile]}"
IID="${2:?Uso: glab-mr-diff.sh namespace/project iid [outfile]}"
OUT="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=glab-env.sh
source "${SCRIPT_DIR}/glab-env.sh"

if [[ -n "${OUT}" ]]; then
  glab_exec mr diff "${IID}" -R "${REPO}" --color=never > "${OUT}"
  echo "OK: diff salvo em ${OUT}"
else
  glab_exec mr diff "${IID}" -R "${REPO}" --color=never
fi
