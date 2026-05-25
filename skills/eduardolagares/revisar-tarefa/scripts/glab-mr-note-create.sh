#!/usr/bin/env bash
# Cria nota/thread no MR. Mensagem via arquivo (evita escaping).
# Uso: glab-mr-note-create.sh <namespace/project> <iid> <arquivo_mensagem>
set -euo pipefail

REPO="${1:?Uso: glab-mr-note-create.sh namespace/project iid message.txt}"
IID="${2:?}"
MSG_FILE="${3:?}"

[[ -f "${MSG_FILE}" ]] || { echo "FAIL: arquivo não encontrado: ${MSG_FILE}" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=glab-env.sh
source "${SCRIPT_DIR}/glab-env.sh"

glab_exec mr note create "${IID}" -R "${REPO}" -m "$(cat "${MSG_FILE}")" || {
  ec=$?
  [[ "$ec" -eq 2 ]] && exit 2
  echo "FAIL: glab mr note create ${IID} -R ${REPO}" >&2
  exit 1
}

echo "OK: nota publicada em ${REPO} !${IID}"
