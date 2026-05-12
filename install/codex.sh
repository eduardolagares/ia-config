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

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --upgrade) UPGRADE=true ;;
    --with-caveman) INSTALL_CAVEMAN=yes ;;
    --without-caveman) INSTALL_CAVEMAN=no ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run] [--upgrade] [--with-caveman | --without-caveman]"
      echo "Cria symlink: ${CODEX_HOME}/AGENTS.md -> ${REPO_ROOT}/codex/AGENTS.md"
      echo "  --upgrade  Só atualiza Karpathy + Caveman; não recria symlinks."
      echo "  CODEX_HOME=...  diretório do Codex (predefinição: ~/.codex)."
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
  echo "Modo upgrade — apenas Karpathy + Caveman (symlinks em $CODEX_HOME/ não são alterados)."
  if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
  echo
  install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" true
  echo
  maybe_install_caveman "$REPO_ROOT" "$DRY_RUN" true
  echo
  if [[ "$DRY_RUN" == true ]]; then echo "Upgrade concluído (dry-run)."; else echo "Upgrade concluído."; fi
  exit 0
fi

echo "Dest:   $CODEX_HOME/AGENTS.md"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run: nada será alterado)"; fi
echo

mkdir -p "$CODEX_HOME"

install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" false
echo

link_repo_path codex/AGENTS.md "$CODEX_HOME/AGENTS.md"

echo
if [[ "$DRY_RUN" == true ]]; then echo "Feito. (dry-run)"; else echo "Feito."; fi

maybe_install_caveman "$REPO_ROOT" "$DRY_RUN" false
