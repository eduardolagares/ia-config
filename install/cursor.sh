#!/usr/bin/env bash
# Copia rules/skills eduardolagares do ia-config para ~/.cursor/ (ou CURSOR_HOME).
# Uso: ./install/cursor.sh | ./install/cursor.sh --dry-run
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${INSTALL_IA_SOURCE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CURSOR_HOME="${CURSOR_HOME:-${HOME}/.cursor}"
DRY_RUN=false

# shellcheck source=lib/karpathy-rules.sh
source "$SCRIPT_DIR/lib/karpathy-rules.sh"
# shellcheck source=lib/ide-sync.sh
source "$SCRIPT_DIR/lib/ide-sync.sh"
# shellcheck source=lib/cursor-hooks.sh
source "$SCRIPT_DIR/lib/cursor-hooks.sh"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run]"
      echo "Sync rules/skills eduardolagares → \$CURSOR_HOME/{rules,skills}/eduardolagares/"
      echo "  Rules: todas alwaysApply + karpathy (gerado após sync)"
      echo "  Remove legado: agendar-revisao-tarefa, executar-revisao-tarefa"
      echo "  Hook opcional: beforeSubmitPrompt → prefetch diff (/revisar-tarefa)"
      echo "  CURSOR_HOME=...  predef.: ~/.cursor"
      echo "  KARPATHY_GUIDELINES_URL=... (predef.: upstream andrej-karpathy-skills)"
      exit 0
      ;;
    *)
      echo "Argumento desconhecido: $arg (usa --help)" >&2
      exit 1
      ;;
  esac
done

echo "Repo:  $REPO_ROOT"
echo "Dest:  $CURSOR_HOME/{rules,skills}/$IA_NAMESPACE/"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
echo

mkdir -p "$CURSOR_HOME"

ia_config_sync_cursor_home "$REPO_ROOT" "$CURSOR_HOME" "$DRY_RUN"
echo

install_karpathy_guidelines "$CURSOR_HOME/rules/$IA_NAMESPACE/karpathy-guidelines.mdc" "$DRY_RUN"
echo

ia_config_install_revisar_tarefa_hook "$CURSOR_HOME" "$REPO_ROOT" "$DRY_RUN"

if [[ "$DRY_RUN" != true ]]; then
  ia_config_print_sync_summary "$CURSOR_HOME/rules" "$CURSOR_HOME/skills"
fi

echo
if [[ "$DRY_RUN" == true ]]; then
  echo "Feito. (dry-run)"
else
  echo "Feito."
  echo "Revisar tarefa: /revisar-tarefa <título> (skill em skills/$IA_NAMESPACE/revisar-tarefa/)"
  echo "Refatorar código: /refatorar-codigo (skill em skills/$IA_NAMESPACE/refatorar-codigo/)"
  echo "Ambiente: validate-env.sh (GitLab) + Monday em Cursor → Settings → MCP"
fi
