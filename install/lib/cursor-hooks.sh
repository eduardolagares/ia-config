#!/usr/bin/env bash
# Remove hook prefetch legado de /revisar-tarefa (diff agora via MCP GitLab na IDE).
# Paths relativos a CURSOR_HOME (~/.cursor ou projeto/.cursor).
set -euo pipefail

_ia_config_hooks_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=ide-sync.sh
source "${_ia_config_hooks_dir}/ide-sync.sh"

ia_config_install_revisar_tarefa_hook() {
  local cursor_home="$1"
  local repo="$2"
  local dry="$3"

  local hooks_dir="${cursor_home}/hooks"
  local hook_dest="${hooks_dir}/revisar-tarefa-prefetch-diff.sh"
  local hooks_json="${cursor_home}/hooks.json"
  local hook_cmd="${cursor_home}/hooks/revisar-tarefa-prefetch-diff.sh"

  echo "Hook revisar-tarefa (legado API) → remover se existir"

  if [[ "$dry" == true ]]; then
    [[ -f "$hook_dest" ]] && echo "[dry-run] rm $hook_dest"
    [[ -f "$hooks_json" ]] && echo "[dry-run] remover beforeSubmitPrompt → $hook_cmd em $hooks_json"
    return 0
  fi

  if [[ -f "$hook_dest" ]]; then
    rm -f "$hook_dest"
    echo "  removido: $hook_dest"
  fi

  if [[ ! -f "$hooks_json" ]]; then
    return 0
  fi

  python3 - "$hooks_json" "$hook_cmd" <<'PY'
import json
import sys
from pathlib import Path

hooks_json = Path(sys.argv[1])
hook_cmd = sys.argv[2]

data = json.loads(hooks_json.read_text(encoding="utf-8"))
hooks = data.get("hooks") or {}
existing = hooks.get("beforeSubmitPrompt") or []
filtered = [h for h in existing if h.get("command") != hook_cmd]
if len(filtered) == len(existing):
    raise SystemExit(0)
hooks["beforeSubmitPrompt"] = filtered
if not filtered:
    hooks.pop("beforeSubmitPrompt", None)
data["hooks"] = hooks
hooks_json.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"  hooks.json: removido beforeSubmitPrompt → {hook_cmd}")
PY
}
