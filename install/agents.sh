#!/usr/bin/env bash
# Copia rules/skills eduardolagares para ~/.agents (ou AGENTS_HOME).
# Uso: ./install/agents.sh | ./install/agents.sh --dry-run
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${INSTALL_IA_SOURCE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
AGENTS_HOME="${AGENTS_HOME:-${HOME}/.agents}"
DRY_RUN=false

# shellcheck source=lib/karpathy-rules.sh
source "$SCRIPT_DIR/lib/karpathy-rules.sh"
# shellcheck source=lib/ide-sync.sh
source "$SCRIPT_DIR/lib/ide-sync.sh"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run]"
      echo "Sync rules/skills eduardolagares → \$AGENTS_HOME/{rules,skills}/eduardolagares/"
      echo "  Apaga {rules,skills}/eduardolagares no destino antes de colar (sync limpo)"
      echo "  Remove legado: agendar/executar-revisao-tarefa, gitlab-api"
      echo "  AGENTS_HOME=...  predef.: ~/.agents"
      exit 0
      ;;
    *)
      echo "Argumento desconhecido: $arg (usa --help)" >&2
      exit 1
      ;;
  esac
done

echo "Repo:  $REPO_ROOT"
echo "Dest:  $AGENTS_HOME/{rules,skills}/$IA_NAMESPACE/"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
echo

BEFORE_MANIFEST=""
if [[ "$DRY_RUN" != true ]]; then
  BEFORE_MANIFEST="$(mktemp)"
  ia_config_write_home_manifest "$AGENTS_HOME" "$BEFORE_MANIFEST"
fi

ia_config_sync_agents_home "$REPO_ROOT" "$AGENTS_HOME" "$DRY_RUN"
echo

install_karpathy_guidelines "$AGENTS_HOME/rules/$IA_NAMESPACE/karpathy-guidelines.mdc" "$DRY_RUN"

if [[ "$DRY_RUN" != true ]]; then
  ia_config_print_sync_summary "$AGENTS_HOME/rules" "$AGENTS_HOME/skills"
fi

echo
if [[ "$DRY_RUN" == true ]]; then
  echo "Feito. (dry-run)"
else
  echo "Feito."
  ia_config_print_home_changes "$BEFORE_MANIFEST" "$AGENTS_HOME"
  rm -f "$BEFORE_MANIFEST"
fi
