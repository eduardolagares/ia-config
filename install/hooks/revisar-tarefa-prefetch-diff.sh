#!/usr/bin/env bash
# beforeSubmitPrompt: prefetch diff GitLab ao enviar /revisar-tarefa (VPN do Mac).
# Instalado em $CURSOR_HOME/hooks/ pelo install/cursor.sh.
set -euo pipefail

CURSOR_HOME="$(cd "$(dirname "$0")/.." && pwd)"
input="$(cat)"
prompt="$(
  printf '%s' "$input" | python3 -c '
import json, sys
raw = sys.stdin.read()
try:
    data = json.loads(raw) if raw.strip() else {}
except json.JSONDecodeError:
    data = {}
for key in ("prompt", "user_message", "text", "message"):
    val = data.get(key)
    if isinstance(val, str) and val.strip():
        print(val.strip())
        break
' 2>/dev/null || true
)"

[[ -z "$prompt" ]] && exit 0

titulo="$(
  printf '%s' "$prompt" | python3 -c '
import re, sys
text = sys.stdin.read().strip()
patterns = [
    r"^/revisar-tarefa\s+(.+)$",
    r"^revisar\s+tarefa\s+(.+)$",
]
for pat in patterns:
    m = re.match(pat, text, re.IGNORECASE | re.DOTALL)
    if m:
        print(m.group(1).strip())
        break
' 2>/dev/null || true
)"

[[ -z "$titulo" ]] && exit 0

prefetch="${CURSOR_HOME}/skills/eduardolagares/revisar-tarefa/scripts/prefetch-diff.sh"
[[ -x "$prefetch" ]] || exit 0

"$prefetch" --titulo "$titulo" --source hook >/dev/null 2>&1 || true
exit 0
