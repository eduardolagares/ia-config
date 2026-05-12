#!/usr/bin/env bash
# Liga este repositório ao OpenAI Codex CLI via ~/.codex/AGENTS.md (ou CODEX_HOME).
# Uso: ./install/codex.sh | ./install/codex.sh --dry-run | ./install/codex.sh --upgrade
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
DRY_RUN=false
UPGRADE=false

# shellcheck source=lib/karpathy-rules.sh
source "$SCRIPT_DIR/lib/karpathy-rules.sh"
# shellcheck source=lib/caveman-install.sh
source "$SCRIPT_DIR/lib/caveman-install.sh"
# shellcheck source=lib/ide-sync.sh
source "$SCRIPT_DIR/lib/ide-sync.sh"

AGENTS_SKILLS_ROOT="${AGENTS_SKILLS_ROOT:-${HOME}/.agents/skills}"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --upgrade) UPGRADE=true ;;
    --with-caveman) INSTALL_CAVEMAN=yes ;;
    --without-caveman) INSTALL_CAVEMAN=no ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run] [--upgrade] [--with-caveman | --without-caveman]"
      echo "Cria symlink: ${CODEX_HOME}/AGENTS.md -> ${REPO_ROOT}/codex/AGENTS.md"
      echo "Gera skills em AGENTS_SKILLS_ROOT (predef.: ~/.agents/skills): cada rule .mdc → ia-rule-*/SKILL.md; cada command → command-*/SKILL.md; copia skills/ do repo."
      echo "  --upgrade  Karpathy, Caveman e re-sync dessas skills (symlink AGENTS.md mantido)."
      echo "  CODEX_HOME=...  diretório do Codex (predefinição: ~/.codex)."
      echo "  AGENTS_SKILLS_ROOT=...  destino das skills (predefinição: ~/.agents/skills)."
      echo "Se existir AGENTS.override.md com conteúdo, o Codex pode ignorar AGENTS.md."
      echo "No fim: pergunta opcional Caveman (clone → skills/)."
      echo "  INSTALL_CAVEMAN=yes|no  CAVEMAN_REPO_URL=..."
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

link_repo_path() {
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

  run "ln -sfn \"$src\" \"$dest\""
  echo "  $dest -> $src"
}

echo "Repo:   $REPO_ROOT"

if [[ "$UPGRADE" == true ]]; then
  echo "Modo upgrade — Karpathy, Caveman e re-sync de skills em $AGENTS_SKILLS_ROOT (symlink $CODEX_HOME/AGENTS.md mantido)."
  if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
  echo
  install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" true
  echo
  maybe_install_caveman "$REPO_ROOT" "$DRY_RUN" true
  echo
  ia_config_sync_codex_managed_skills "$REPO_ROOT" "$AGENTS_SKILLS_ROOT" "$DRY_RUN"
  echo
  if [[ "$DRY_RUN" == true ]]; then echo "Upgrade concluído (dry-run)."; else echo "Upgrade concluído."; fi
  exit 0
fi

echo "Dest:   $CODEX_HOME/AGENTS.md + $AGENTS_SKILLS_ROOT/{ia-rule-*,command-*,...}/"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run: nada será alterado)"; fi
echo

mkdir -p "$CODEX_HOME"

install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" false
echo

link_repo_path codex/AGENTS.md "$CODEX_HOME/AGENTS.md"
echo

maybe_install_caveman "$REPO_ROOT" "$DRY_RUN" false
echo

ia_config_sync_codex_managed_skills "$REPO_ROOT" "$AGENTS_SKILLS_ROOT" "$DRY_RUN"

echo
if [[ "$DRY_RUN" == true ]]; then echo "Feito. (dry-run)"; else echo "Feito."; fi
