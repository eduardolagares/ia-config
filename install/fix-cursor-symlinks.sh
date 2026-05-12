#!/usr/bin/env bash
# Substitui symlinks em CURSOR_HOME/{rules,skills,commands} por pastas reais
# (cópia do destino resolvido). Útil após migração do instalador antigo.
# Uso: bash install/fix-cursor-symlinks.sh [--dry-run]
set -euo pipefail

CURSOR_HOME="${CURSOR_HOME:-${HOME}/.cursor}"
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h | --help)
      echo "Uso: $(basename "$0") [--dry-run]"
      echo "Para cada uma de rules, skills, commands em $CURSOR_HOME:"
      echo "  - se for symlink: copia o conteúdo resolvido para uma pasta nova e remove o link."
      echo "  - se já for pasta normal: não altera."
      echo "Variável: CURSOR_HOME (predef.: ~/.cursor)."
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

resolve_realpath() {
  python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

migrate_dir() {
  local name="$1"
  local dest="$CURSOR_HOME/$name"

  if [[ -L "$dest" ]]; then
    local src
    src="$(resolve_realpath "$dest")"
    if [[ ! -d "$src" ]]; then
      echo "Erro: symlink $dest aponta para algo que não é pasta: $src" >&2
      return 1
    fi
    echo "Migrar $name: symlink → cópia (origem: $src)"
    local staging="${dest}.__ia_config_migrate.$$"
    run "mkdir -p \"$CURSOR_HOME\""
    run "cp -R \"$src\" \"$staging\""
    run "rm -f \"$dest\""
    run "mv \"$staging\" \"$dest\""
    return 0
  fi

  if [[ -d "$dest" ]]; then
    echo "OK $name: já é pasta (sem symlink)."
    return 0
  fi

  if [[ -e "$dest" ]]; then
    echo "AVISO $name: existe mas não é pasta nem symlink — não alterado: $dest" >&2
    return 0
  fi

  echo "(inexistente) $name — nada a fazer."
}

echo "CURSOR_HOME=$CURSOR_HOME"
if [[ "$DRY_RUN" == true ]]; then echo "(dry-run)"; fi
echo

mkdir -p "$CURSOR_HOME"

migrate_dir rules
migrate_dir skills
migrate_dir commands

echo
if [[ "$DRY_RUN" == true ]]; then echo "Concluído (dry-run)."; else echo "Concluído."; fi
