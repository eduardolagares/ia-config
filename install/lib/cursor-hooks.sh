#!/usr/bin/env bash
# Instala hook beforeSubmitPrompt para prefetch de diff (/revisar-tarefa).
# Paths relativos a CURSOR_HOME (~/.cursor ou projeto/.cursor).
set -euo pipefail

_ia_config_hooks_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=ide-sync.sh
source "${_ia_config_hooks_dir}/ide-sync.sh"

ia_config_install_revisar_tarefa_hook() {
  local cursor_home="$1"
  local repo="$2"
  local dry="$3"

  local hook_src="${repo}/install/hooks/revisar-tarefa-prefetch-diff.sh"
  local hooks_dir="${cursor_home}/hooks"
  local hook_dest="${hooks_dir}/revisar-tarefa-prefetch-diff.sh"
  local hooks_json="${cursor_home}/hooks.json"
  local hook_cmd="${cursor_home}/hooks/revisar-tarefa-prefetch-diff.sh"

  if [[ ! -f "$hook_src" ]]; then
    echo "AVISO: hook ausente no repo: $hook_src" >&2
    return 0
  fi

  echo "Hook revisar-tarefa → ${hook_dest}"

  if [[ "$dry" == true ]]; then
    echo "[dry-run] cp $hook_src → $hook_dest"
    echo "[dry-run] merge beforeSubmitPrompt em $hooks_json"
    return 0
  fi

  mkdir -p "$hooks_dir"
  cp "$hook_src" "$hook_dest"
  chmod +x "$hook_dest"

  python3 - "$hooks_json" "$hook_cmd" <<'PY'
import json
import sys
from pathlib import Path

hooks_json = Path(sys.argv[1])
hook_cmd = sys.argv[2]

entry = {"command": hook_cmd}

if hooks_json.is_file():
    data = json.loads(hooks_json.read_text(encoding="utf-8"))
else:
    data = {"version": 1, "hooks": {}}

hooks = data.setdefault("hooks", {})
existing = hooks.setdefault("beforeSubmitPrompt", [])
if not any(h.get("command") == hook_cmd for h in existing):
    existing.append(entry)

hooks_json.parent.mkdir(parents=True, exist_ok=True)
hooks_json.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"  hooks.json: beforeSubmitPrompt → {hook_cmd}")
PY
}
