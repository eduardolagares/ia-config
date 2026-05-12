#!/usr/bin/env bash
# Copia rules, skills e commands do ia-config para ~/.cursor/ (ou CURSOR_HOME).
# Uso: ./install/cursor.sh | ./install/cursor.sh --dry-run | ./install/cursor.sh --upgrade
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${INSTALL_IA_SOURCE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CURSOR_HOME="${CURSOR_HOME:-${HOME}/.cursor}"
DRY_RUN=false
UPGRADE=false

# shellcheck source=lib/karpathy-rules.sh
source "$SCRIPT_DIR/lib/karpathy-rules.sh"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --upgrade) UPGRADE=true ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run] [--upgrade]"
      echo "Substitui $CURSOR_HOME/{rules,skills,commands} por cópias das pastas do repo (sem symlinks)."
      echo "  CURSOR_HOME=...  destino (predef.: ~/.cursor; em projeto: /caminho/.cursor)."
      echo "  --upgrade  Só atualiza Karpathy; não substitui rules/skills/commands em CURSOR_HOME."
      echo "  Descarrega obrigatoriamente Karpathy a partir do SKILL.md upstream (forrestchang/andrej-karpathy-skills)."
      echo "  KARPATHY_GUIDELINES_URL=...  URL raw alternativa (predef.: .../skills/karpathy-guidelines/SKILL.md)."
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

# Remove $dest (pasta, ficheiro ou symlink) e copia $src -> $dest (pasta).
copy_repo_dir() {
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

  run "mkdir -p \"$CURSOR_HOME\""
  run "cp -R \"$src\" \"$dest\""
  echo "  $dest (cópia de $src)"
}

echo "Repo:  $REPO_ROOT"

if [[ "$UPGRADE" == true ]]; then
  echo "Modo upgrade — apenas Karpathy (cópias em $CURSOR_HOME não são alteradas neste passo)."
  if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
  echo
  install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" true
  echo
  if [[ "$DRY_RUN" == true ]]; then echo "Upgrade concluído (dry-run)."; else echo "Upgrade concluído."; fi
  exit 0
fi

echo "Dest:  cópias de pasta em $CURSOR_HOME/"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run: nada será alterado)"; fi
echo

mkdir -p "$CURSOR_HOME"

install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN" false
echo

copy_repo_dir rules
echo
copy_repo_dir skills
echo
copy_repo_dir commands

echo
if [[ "$DRY_RUN" == true ]]; then echo "Feito. (dry-run)"; else echo "Feito."; fi
