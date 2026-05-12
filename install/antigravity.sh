#!/usr/bin/env bash
# Liga este repositório ao Google Antigravity via ficheiros em ~/.gemini/
# (regras globais: GEMINI.md e AGENTS.md; ver documentação Antigravity).
# Uso: ./install/antigravity.sh | ./install/antigravity.sh --dry-run | ./install/antigravity.sh --upgrade
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GEMINI_HOME="${GEMINI_HOME:-${HOME}/.gemini}"
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
      echo "Cria symlinks em ${GEMINI_HOME}/ para:"
      echo "  GEMINI.md  -> ${REPO_ROOT}/antigravity/GEMINI.md"
      echo "  AGENTS.md  -> ${REPO_ROOT}/antigravity/AGENTS.md"
      echo "  --upgrade  Só atualiza Karpathy + Caveman; não recria symlinks."
      echo "  GEMINI_HOME=...  diretório base (predefinição: ~/.gemini)."
      echo "Aviso: GEMINI.md pode ser partilhado com o Gemini CLI (mesmo path)."
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

# Remove dest se existir; cria dest -> src (ficheiro ou pasta).
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
  echo "Modo upgrade — apenas Karpathy + Caveman (symlinks em $GEMINI_HOME/ não são alterados)."
  if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
  echo
  install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" true
  echo
  maybe_install_caveman "$REPO_ROOT" "$DRY_RUN" true
  echo
  if [[ "$DRY_RUN" == true ]]; then echo "Upgrade concluído (dry-run)."; else echo "Upgrade concluído."; fi
  exit 0
fi

echo "Dest:   $GEMINI_HOME/{GEMINI.md,AGENTS.md}"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run: nada será alterado)"; fi
echo

mkdir -p "$GEMINI_HOME"

install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" false
echo

link_repo_path antigravity/GEMINI.md "$GEMINI_HOME/GEMINI.md"
echo
link_repo_path antigravity/AGENTS.md "$GEMINI_HOME/AGENTS.md"

echo
if [[ "$DRY_RUN" == true ]]; then echo "Feito. (dry-run)"; else echo "Feito."; fi

maybe_install_caveman "$REPO_ROOT" "$DRY_RUN" false
