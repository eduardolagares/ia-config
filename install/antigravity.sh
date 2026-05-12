#!/usr/bin/env bash
# Copia GEMINI.md e AGENTS.md e converte rules/workflows/skills para ~/.gemini/
# Uso: ./install/antigravity.sh | ./install/antigravity.sh --dry-run | ./install/antigravity.sh --upgrade
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${INSTALL_IA_SOURCE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
GEMINI_HOME="${GEMINI_HOME:-${HOME}/.gemini}"
DRY_RUN=false
UPGRADE=false

# shellcheck source=lib/karpathy-rules.sh
source "$SCRIPT_DIR/lib/karpathy-rules.sh"
# shellcheck source=lib/ide-sync.sh
source "$SCRIPT_DIR/lib/ide-sync.sh"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --upgrade) UPGRADE=true ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run] [--upgrade]"
      echo "Copia ficheiros para ${GEMINI_HOME}/ (sem symlinks):"
      echo "  GEMINI.md  <- ${REPO_ROOT}/antigravity/GEMINI.md"
      echo "  AGENTS.md  <- ${REPO_ROOT}/antigravity/AGENTS.md"
      echo "Além disso: rules convertidas em antigravity/ia-config/rules/ ; commands em antigravity/global_workflows/ ; skills em antigravity/skills/."
      echo "  --upgrade  Karpathy, re-cópia GEMINI/AGENTS e re-sync das pastas antigravity acima."
      echo "  GEMINI_HOME=...  diretório base (predefinição: ~/.gemini)."
      echo "Aviso: GEMINI.md pode ser partilhado com o Gemini CLI (mesmo path)."
      echo "  Karpathy: SKILL.md upstream → rules/karpathy-guidelines.mdc (KARPATHY_GUIDELINES_URL=... opcional)."
      exit 0
      ;;
  esac
done

run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] $*"
  else
    eval "$1"
  fi
}

copy_repo_file() {
  local rel="$1"
  local dest="$2"
  local src="$REPO_ROOT/$rel"

  if [[ ! -e "$src" ]]; then
    echo "Erro: origem inexistente no repo: $src" >&2
    return 1
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "A remover destino existente: $dest" >&2
    run "rm -rf \"$dest\""
  fi

  run "mkdir -p \"$(dirname "$dest")\""
  run "cp \"$src\" \"$dest\""
  echo "  $dest (cópia de $src)"
}

echo "Repo:   $REPO_ROOT"

if [[ "$UPGRADE" == true ]]; then
  echo "Modo upgrade — Karpathy, re-cópia GEMINI.md/AGENTS.md e re-sync em $GEMINI_HOME/antigravity/."
  if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
  echo
  install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" true
  echo
  copy_repo_file antigravity/GEMINI.md "$GEMINI_HOME/GEMINI.md"
  echo
  copy_repo_file antigravity/AGENTS.md "$GEMINI_HOME/AGENTS.md"
  echo
  ia_config_sync_antigravity_rules_workflows "$REPO_ROOT" "$GEMINI_HOME" "$DRY_RUN"
  echo
  ia_config_sync_antigravity_skills "$REPO_ROOT" "$GEMINI_HOME" "$DRY_RUN"
  echo
  if [[ "$DRY_RUN" == true ]]; then echo "Upgrade concluído (dry-run)."; else echo "Upgrade concluído."; fi
  exit 0
fi

echo "Dest:   $GEMINI_HOME/{GEMINI.md,AGENTS.md} + $GEMINI_HOME/antigravity/{ia-config/rules,global_workflows,skills}/"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run: nada será alterado)"; fi
echo

mkdir -p "$GEMINI_HOME"

install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" false
echo

copy_repo_file antigravity/GEMINI.md "$GEMINI_HOME/GEMINI.md"
echo
copy_repo_file antigravity/AGENTS.md "$GEMINI_HOME/AGENTS.md"
echo

ia_config_sync_antigravity_rules_workflows "$REPO_ROOT" "$GEMINI_HOME" "$DRY_RUN"
echo

ia_config_sync_antigravity_skills "$REPO_ROOT" "$GEMINI_HOME" "$DRY_RUN"

echo
if [[ "$DRY_RUN" == true ]]; then echo "Feito. (dry-run)"; else echo "Feito."; fi
