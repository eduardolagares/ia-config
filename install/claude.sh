#!/usr/bin/env bash
# Liga este repositório ao Claude Code: ~/.claude/{rules,commands,skills}/ (cópias convertidas).
# Respeita CLAUDE_CONFIG_DIR se definido (https://code.claude.com/en/env-vars).
# Uso: ./install/claude.sh | ./install/claude.sh --dry-run | ./install/claude.sh --upgrade
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${INSTALL_IA_SOURCE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
DRY_RUN=false
UPGRADE=false

# shellcheck source=lib/karpathy-rules.sh
source "$SCRIPT_DIR/lib/karpathy-rules.sh"
# shellcheck source=lib/caveman-install.sh
source "$SCRIPT_DIR/lib/caveman-install.sh"
# shellcheck source=lib/ide-sync.sh
source "$SCRIPT_DIR/lib/ide-sync.sh"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --upgrade) UPGRADE=true ;;
    --with-caveman) INSTALL_CAVEMAN=yes ;;
    --without-caveman) INSTALL_CAVEMAN=no ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run] [--upgrade] [--with-caveman | --without-caveman]"
      echo "Escreve ~/.claude/{rules,commands,skills}/ : rules .mdc→.md (globs→paths), commands com paths ~/.claude/commands/, skills a partir de skills/ do repo."
      echo "  CLAUDE_CONFIG_DIR=...  (opcional; predef.: ~/.claude)."
      echo "  --upgrade  Karpathy, Caveman e re-sync de rules/commands/skills em ~/.claude (ou CLAUDE_CONFIG_DIR)."
      echo "No fim: pergunta se queres instalar skills Caveman (clone JuliusBrussee/caveman → skills/)."
      echo "  Descarrega obrigatoriamente Karpathy a partir do SKILL.md upstream (forrestchang/andrej-karpathy-skills)."
      echo "  KARPATHY_GUIDELINES_URL=...  URL raw alternativa do SKILL.md."
      echo "  INSTALL_CAVEMAN=yes|no  evita a pergunta (útil em CI)."
      echo "  CAVEMAN_REPO_URL=...     URL alternativa do repositório Caveman."
      echo "Refs: https://code.claude.com/docs/en/claude-directory"
      exit 0
      ;;
  esac
done

echo "Repo:   $REPO_ROOT"

if [[ "$UPGRADE" == true ]]; then
  echo "Modo upgrade — Karpathy, Caveman e re-sync de rules/commands/skills em $CLAUDE_HOME."
  [[ -n "${CLAUDE_CONFIG_DIR:-}" ]] && echo "(CLAUDE_CONFIG_DIR está definido)"
  if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
  echo
  install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" true
  echo
  maybe_install_caveman "$REPO_ROOT" "$DRY_RUN" true
  echo
  ia_config_sync_claude_rules_and_commands "$REPO_ROOT" "$CLAUDE_HOME" "$DRY_RUN"
  echo
  ia_config_sync_claude_skills "$REPO_ROOT" "$CLAUDE_HOME" "$DRY_RUN"
  echo
  if [[ "$DRY_RUN" == true ]]; then echo "Upgrade concluído (dry-run)."; else echo "Upgrade concluído."; fi
  exit 0
fi

echo "Dest:   $CLAUDE_HOME/{rules,commands,skills}/ (ficheiros gerados a partir do repo)"
[[ -n "${CLAUDE_CONFIG_DIR:-}" ]] && echo "(CLAUDE_CONFIG_DIR está definido)"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run: nada será alterado)"; fi
echo

mkdir -p "$CLAUDE_HOME"

install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" false
echo

ia_config_sync_claude_rules_and_commands "$REPO_ROOT" "$CLAUDE_HOME" "$DRY_RUN"
echo

maybe_install_caveman "$REPO_ROOT" "$DRY_RUN" false
echo

ia_config_sync_claude_skills "$REPO_ROOT" "$CLAUDE_HOME" "$DRY_RUN"

echo
if [[ "$DRY_RUN" == true ]]; then echo "Feito. (dry-run)"; else echo "Feito."; fi
