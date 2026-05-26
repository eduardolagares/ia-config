#!/usr/bin/env bash
# Legado: redireciona para gitlab-api-validate.sh (GITLAB_TOKEN + REST API).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "WARN: glab-validate.sh está obsoleto — use gitlab-api-validate.sh" >&2
exec "${SCRIPT_DIR}/gitlab-api-validate.sh" "$@"
