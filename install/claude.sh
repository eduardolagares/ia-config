#!/usr/bin/env bash
# Liga este repositório ao Claude Code via symlinks de PASTAS em ~/.claude/
# Respeita CLAUDE_CONFIG_DIR se definido (https://code.claude.com/en/env-vars).
# Uso: ./install/claude.sh | ./install/claude.sh --dry-run
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
DRY_RUN=false

# shellcheck source=lib/karpathy-rules.sh
source "$SCRIPT_DIR/lib/karpathy-rules.sh"
# shellcheck source=lib/caveman-install.sh
source "$SCRIPT_DIR/lib/caveman-install.sh"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --with-caveman) INSTALL_CAVEMAN=yes ;;
    --without-caveman) INSTALL_CAVEMAN=no ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run] [--with-caveman | --without-caveman]"
      echo "Substitui rules/skills/commands (pasta ou symlink) por symlink para o repo em ~/.claude ou CLAUDE_CONFIG_DIR."
      echo "No fim: pergunta se queres instalar skills Caveman (clone JuliusBrussee/caveman → skills/)."
      echo "  Descarrega obrigatoriamente rules/karpathy-guidelines.mdc (curl) de forrestchang/andrej-karpathy-skills."
      echo "  KARPATHY_GUIDELINES_URL=...  URL raw alternativa do .mdc."
      echo "  INSTALL_CAVEMAN=yes|no  evita a pergunta (útil em CI)."
      echo "  CAVEMAN_REPO_URL=...     URL alternativa do repositório Caveman."
      echo "Refs: https://code.claude.com/docs/en/claude-directory"
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
  local dest="$CLAUDE_HOME/$name"

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

echo "Repo:   $REPO_ROOT"
echo "Dest:   symlinks de pasta em $CLAUDE_HOME/"
[[ -n "${CLAUDE_CONFIG_DIR:-}" ]] && echo "(CLAUDE_CONFIG_DIR está definido)"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run: nada será alterado)"; fi
echo
echo "Nota: Claude Code carrega rules como rules/*.md; ficheiros .mdc (Cursor) podem não ser lidos até duplicares ou renomeares para .md."
echo

mkdir -p "$CLAUDE_HOME"

install_karpathy_guidelines "$REPO_ROOT" "$DRY_RUN"
echo

link_repo_dir rules
echo
link_repo_dir skills
echo
link_repo_dir commands

echo
if [[ "$DRY_RUN" == true ]]; then echo "Feito. (dry-run)"; else echo "Feito."; fi

maybe_install_caveman "$REPO_ROOT" "$DRY_RUN"
