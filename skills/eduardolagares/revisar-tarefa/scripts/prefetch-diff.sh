#!/usr/bin/env bash
# Pré-busca diff GitLab via REST API e grava cache para /revisar-tarefa.
# Uso:
#   prefetch-diff.sh --titulo "Título exato" [--source hook|manual|agent]
#   prefetch-diff.sh --branch dev-x --repo baladapp/foo [--repo baladapp/bar ...]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

resolve_monday_cache() {
  local candidate
  for candidate in \
    "${SKILL_ROOT}/../monday-task-info/cache/tasks-by-title.json" \
    "${HOME}/.agents/skills/eduardolagares/monday-task-info/cache/tasks-by-title.json" \
    "${HOME}/.cursor/skills/eduardolagares/monday-task-info/cache/tasks-by-title.json" \
    "${HOME}/.agents/skills/monday-task-info/cache/tasks-by-title.json" \
    "${HOME}/.cursor/skills/monday-task-info/cache/tasks-by-title.json"; do
    if [[ -f "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return 0
    fi
  done
  printf '%s' "${HOME}/.agents/skills/eduardolagares/monday-task-info/cache/tasks-by-title.json"
}

MONDAY_CACHE="$(resolve_monday_cache)"
CACHE_DIR="${SKILL_ROOT}/cache"
CACHE_FILE="${CACHE_DIR}/last-diff-bundle.json"
BUNDLE_SCRIPT_API="${SCRIPT_DIR}/gitlab-api-phase3-diff-bundle.sh"
MAX_AGE_MINUTES="${REVISAR_TAREFA_DIFF_CACHE_TTL_MIN:-120}"

run_diff_bundle() {
  local tmp_out="$1"
  local tmp_err="$2"
  set +e
  "${BUNDLE_SCRIPT_API}" "${BRANCH}" "${REPOS[@]}" >"${tmp_out}" 2>"${tmp_err}"
  local ec=$?
  set -e
  return "${ec}"
}

SOURCE="manual"
TITULO=""
BRANCH=""
REPOS=()

usage() {
  echo "Uso: prefetch-diff.sh --titulo \"...\" | --branch BR --repo baladapp/x ..." >&2
  exit 1
}

map_repo() {
  local raw="$1"
  raw="${raw#"${raw%%[![:space:]]*}"}"
  raw="${raw%"${raw##*[![:space:]]}"}"
  [[ -z "${raw}" ]] && return 1
  if [[ "${raw}" == */* ]]; then
    echo "${raw}"
    return 0
  fi
  case "${raw}" in
    baladapp-react-components) echo "baladapp/baladapp-react-components" ;;
    ingressos-repo) echo "baladapp/ingressos" ;;
    *) echo "baladapp/${raw}" ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --titulo) TITULO="${2:?}"; shift 2 ;;
    --branch) BRANCH="${2:?}"; shift 2 ;;
    --repo) REPOS+=("${2:?}"); shift 2 ;;
    --source) SOURCE="${2:?}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Argumento desconhecido: $1" >&2; usage ;;
  esac
done

if [[ -n "${TITULO}" && -z "${BRANCH}" ]]; then
  if [[ ! -f "${MONDAY_CACHE}" ]]; then
    echo "CACHE_SKIP: monday cache ausente (${MONDAY_CACHE})" >&2
    exit 0
  fi
  _py_out="$(python3 - "${TITULO}" "${MONDAY_CACHE}" <<'PY'
import json, sys
titulo, path = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
entry = data.get(titulo.strip())
if not entry:
    sys.exit(0)
branch = (entry.get("branch") or "").strip()
projetos = entry.get("projetos_alterados") or []
print(branch)
print(json.dumps(projetos, ensure_ascii=False))
PY
  )"
  BRANCH="$(echo "${_py_out}" | sed -n '1p')"
  REPOS_JSON="$(echo "${_py_out}" | sed -n '2p')"
  if [[ -z "${BRANCH}" ]]; then
    echo "CACHE_SKIP: título sem branch no monday cache" >&2
    exit 0
  fi
  while IFS= read -r p; do
    [[ -z "${p}" ]] && continue
    mapped="$(map_repo "${p}")" || continue
    REPOS+=("${mapped}")
  done < <(echo "${REPOS_JSON}" | python3 -c 'import json,sys; [print(x) for x in json.load(sys.stdin)]')
fi

if [[ -z "${BRANCH}" || ${#REPOS[@]} -eq 0 ]]; then
  echo "CACHE_SKIP: branch ou repos vazios" >&2
  exit 0
fi

mkdir -p "${CACHE_DIR}"
tmp_json="$(mktemp "${CACHE_DIR}/bundle.XXXXXX.json")"
trap 'rm -f "${tmp_json}"' EXIT

set +e
run_diff_bundle "${tmp_json}" "${tmp_json}.err"
bundle_ec=$?
set -e

python3 - "${CACHE_FILE}" "${tmp_json}" "${bundle_ec}" "${SOURCE}" "${TITULO}" "${BRANCH}" "${REPOS[@]}" <<'PY'
import json, sys
from datetime import datetime, timezone

out_path, bundle_path = sys.argv[1], sys.argv[2]
bundle_ec = int(sys.argv[3])
source = sys.argv[4]
titulo = sys.argv[5]
branch = sys.argv[6]
repos = sys.argv[7:]

with open(bundle_path, encoding="utf-8") as f:
    raw = f.read().strip()
try:
    bundle = json.loads(raw) if raw else {}
except json.JSONDecodeError:
    bundle = {"parse_error": True, "raw_preview": raw[:2000]}

payload = {
    "titulo": titulo or None,
    "branch": branch,
    "repos": repos,
    "fetched_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "source": source,
    "fetch_mode": "api",
    "bundle_exit_code": bundle_ec,
    "bundle": bundle,
}
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(payload, f, ensure_ascii=False, indent=2)
print(f"CACHE_SAVED {out_path} branch={branch} repos={len(repos)} ec={bundle_ec}")
PY

if [[ "${bundle_ec}" -eq 2 ]]; then
  cat "${tmp_json}.err" >&2 || true
  exit 2
fi
exit "${bundle_ec}"
