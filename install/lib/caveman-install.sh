#!/usr/bin/env bash
# Instalação opcional das skills Caveman a partir do repositório upstream.
# Carregado pelos scripts install/*.sh (Cursor, Claude, Antigravity, Codex).

CAVEMAN_REPO_URL="${CAVEMAN_REPO_URL:-https://github.com/JuliusBrussee/caveman.git}"

prompt_install_caveman() {
  local for_upgrade="${1:-false}"
  local verb="Instalar"
  [[ "$for_upgrade" == true ]] && verb="Atualizar"
  local reply
  echo
  if [[ -r /dev/tty ]]; then
    read -r -p "${verb} skills Caveman (clone de ${CAVEMAN_REPO_URL})? [s/N] " reply </dev/tty
  else
    read -r -p "${verb} skills Caveman (clone de ${CAVEMAN_REPO_URL})? [s/N] " reply
  fi
  case "$(echo "${reply:-}" | tr '[:upper:]' '[:lower:]')" in
    s | sim | y | yes) return 0 ;;
    *) return 1 ;;
  esac
}

install_caveman_skills() {
  local repo_root="$1"
  local tmp tmp_repo

  if ! command -v git >/dev/null 2>&1; then
    echo "Erro: git é necessário para clonar o Caveman. Instala git e volta a correr." >&2
    return 1
  fi

  tmp="$(mktemp -d)"
  tmp_repo="$tmp/caveman"
  echo "A clonar Caveman (shallow)..."
  if ! git clone --depth 1 "$CAVEMAN_REPO_URL" "$tmp_repo"; then
    rm -rf "$tmp"
    echo "Erro: git clone falhou." >&2
    return 1
  fi

  if [[ ! -d "$tmp_repo/skills" ]]; then
    rm -rf "$tmp"
    echo "Erro: repositório sem pasta skills/." >&2
    return 1
  fi

  mkdir -p "$repo_root/skills"
  # Copia cada skill para skills/ do repo (paths em .gitignore); sobrescreve instalação anterior.
  shopt -s nullglob
  local d
  for d in "$tmp_repo/skills"/*; do
    [[ -d "$d" ]] || continue
    rm -rf "$repo_root/skills/$(basename "$d")"
    cp -R "$d" "$repo_root/skills/"
  done
  shopt -u nullglob

  rm -rf "$tmp"
  echo "Skills Caveman copiadas para $repo_root/skills (ficheiros ignorados pelo Git)."
}

# Decide e executa instalação Caveman após a cópia/sync principal (ou só no modo --upgrade).
# Args: repo_root, dry_run (true/false), for_upgrade (true/false) — se true, prompt fala em "Atualizar".
maybe_install_caveman() {
  local repo_root="$1"
  local dry_run="$2"
  local for_upgrade="${3:-false}"
  local pref="${INSTALL_CAVEMAN:-}"

  if [[ "$dry_run" == true ]]; then
    echo
    if [[ "$for_upgrade" == true ]]; then
      echo "[dry-run] Caveman: pergunta ou INSTALL_CAVEMAN / --with-caveman (modo upgrade não altera cópias Cursor)."
    else
      echo "[dry-run] No fim seria perguntado se queres instalar Caveman (ou usar --with-caveman / INSTALL_CAVEMAN=yes)."
    fi
    return 0
  fi

  case "$pref" in
    yes | true | 1)
      install_caveman_skills "$repo_root"
      return
      ;;
    no | false | 0)
      return 0
      ;;
  esac

  if prompt_install_caveman "$for_upgrade"; then
    install_caveman_skills "$repo_root"
  else
    if [[ "$for_upgrade" == true ]]; then
      echo "(Caveman não atualizado.)"
    else
      echo "(Caveman não instalado; podes correr de novo o script ou definir INSTALL_CAVEMAN=yes.)"
    fi
  fi
}
