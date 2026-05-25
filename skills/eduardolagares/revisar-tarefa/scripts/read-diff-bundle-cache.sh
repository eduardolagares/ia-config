#!/usr/bin/env bash
# Valida e resume o cache de diff para o passo 3.
# Uso: read-diff-bundle-cache.sh --branch BR [--titulo "T"] [--max-age-minutes 120]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CACHE_FILE="${SKILL_ROOT}/cache/last-diff-bundle.json"
BRANCH=""
TITULO=""
MAX_AGE="${REVISAR_TAREFA_DIFF_CACHE_TTL_MIN:-120}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) BRANCH="${2:?}"; shift 2 ;;
    --titulo) TITULO="${2:?}"; shift 2 ;;
    --max-age-minutes) MAX_AGE="${2:?}"; shift 2 ;;
    *) echo "Uso: read-diff-bundle-cache.sh --branch BR [--titulo T]" >&2; exit 1 ;;
  esac
done

[[ -z "${BRANCH}" ]] && { echo "CACHE_MISS: branch obrigatório"; exit 1; }
[[ ! -f "${CACHE_FILE}" ]] && { echo "CACHE_MISS: arquivo ausente"; exit 1; }

python3 - "${CACHE_FILE}" "${BRANCH}" "${TITULO}" "${MAX_AGE}" <<'PY'
import json, sys
from datetime import datetime, timezone

path, want_branch, want_titulo, max_age_min = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
with open(path, encoding="utf-8") as f:
    data = json.load(f)

def miss(reason):
    print(f"CACHE_MISS: {reason}")
    raise SystemExit(1)

branch = (data.get("branch") or "").strip()
if branch != want_branch.strip():
    miss(f"branch cache={branch!r} pedido={want_branch!r}")

titulo = data.get("titulo")
if want_titulo and titulo and titulo.strip() != want_titulo.strip():
    miss(f"titulo cache={titulo!r} pedido={want_titulo!r}")

fetched = data.get("fetched_at")
if fetched:
    try:
        ts = datetime.fromisoformat(fetched.replace("Z", "+00:00"))
        age = (datetime.now(timezone.utc) - ts).total_seconds() / 60
        if age > max_age_min:
            miss(f"expirado ({age:.0f}min > {max_age_min}min)")
    except ValueError:
        pass

ec = data.get("bundle_exit_code", 1)
bundle = data.get("bundle") or {}
projects = bundle.get("projects") or []
ok = [p for p in projects if p.get("diff_file") and not p.get("error")]
if ec != 0 or not ok:
    miss(f"bundle sem diffs (exit={ec}, ok={len(ok)}/{len(projects)})")

print("CACHE_HIT")
print(f"branch={branch}")
print(f"fetched_at={fetched}")
print(f"source={data.get('source')}")
print(f"bundle_exit_code={ec}")
print(f"repos_ok={len(ok)}/{len(projects)}")
print(f"cache_file={path}")
print(f"run_dir={bundle.get('run_dir')}")
for p in projects:
    repo = p.get("repo", "?")
    method = p.get("method") or "-"
    err = p.get("error")
    df = p.get("diff_file") or ""
    print(f"  - {repo}: method={method} bytes={p.get('diff_bytes', 0)} file={df} error={err or ''}")
PY
