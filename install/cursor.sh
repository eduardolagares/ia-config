#!/usr/bin/env bash
# Liga este repositório ao Cursor via symlinks de PASTAS em ~/.cursor/
# Uso: ./install/cursor.sh | ./install/cursor.sh --dry-run
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURSOR_HOME="${HOME}/.cursor"
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      echo "Uso: $(basename "$0") [--dry-run]"
      echo "Substitui ~/.cursor/{rules,skills,commands} (pasta ou symlink) por symlink para o repo."
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

# Remove $dest se existir (pasta, ficheiro ou symlink) e cria $dest -> $src.
link_repo_dir() {
  local name="$1"
  local src="$REPO_ROOT/$name"
  local dest="$CURSOR_HOME/$name"

  if [[ ! -d "$src" ]]; then
    echo "AVISO: pasta inexistente no repo: $src" >&2
    return 0
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "A remover destino existente: $dest" >&2
    run "rm -rf \"$dest\""
  fi

  run "ln -sfn \"$src\" \"$dest\""
  echo "  $dest -> $src"
}

echo "Repo:  $REPO_ROOT"
echo "Dest:  symlinks de pasta em $CURSOR_HOME/"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run: nada será alterado)"; fi
echo

mkdir -p "$CURSOR_HOME"

link_repo_dir rules
echo
link_repo_dir skills
echo
link_repo_dir commands

echo
if [[ "$DRY_RUN" == true ]]; then echo "Feito. (dry-run)"; else echo "Feito."; fi
