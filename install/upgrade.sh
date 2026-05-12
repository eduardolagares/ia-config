#!/usr/bin/env bash
# Atualização: clona eduardolagares/ia-config (main) em /tmp, sincroniza ficheiros
# com os destinos de instalação (novos ficheiros do repo são copiados; Cursor:
# rules/skills/commands substituídos pelo conteúdo atual do repo).
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/upgrade.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/upgrade.sh | bash -s -- --dry-run
set -euo pipefail

REPO_URL="https://github.com/eduardolagares/ia-config.git"
REPO_BRANCH="main"

EXTRA_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) EXTRA_ARGS+=(--dry-run) ;;
    -h | --help)
      echo "Uso: curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/upgrade.sh | bash"
      echo "     curl -fsSL …/install/upgrade.sh | bash -s -- --dry-run"
      echo "Clona ${REPO_URL} (${REPO_BRANCH}) para /tmp; pergunta destino (global/projeto) e agentes;"
      echo "sincroniza a partir do clone (Cursor: pastas rules/skills/commands; outros: mesmo fluxo que --upgrade)."
      exit 0
      ;;
    *)
      echo "Argumento desconhecido: $arg (usa --help)" >&2
      exit 1
      ;;
  esac
done

read_tty() {
  if ( : </dev/tty ) 2>/dev/null; then
    read -r "$@" </dev/tty
  else
    read -r "$@"
  fi
}

prompt_yn() {
  local msg="$1"
  local def="${2:-n}"
  local hint="[s/N]"
  [[ "$def" == "y" ]] && hint="[S/n]"
  local r=""
  read_tty -r -p "$msg $hint " r || true
  r=$(echo "${r:-}" | tr '[:upper:]' '[:lower:]')
  if [[ -z "$r" ]]; then
    [[ "$def" == "y" ]] && return 0 || return 1
  fi
  case "$r" in s | sim | y | yes) return 0 ;; *) return 1 ;; esac
}

if ! command -v git >/dev/null 2>&1; then
  echo "Erro: git é necessário." >&2
  exit 1
fi
if ! command -v curl >/dev/null 2>&1; then
  echo "Erro: curl é necessário." >&2
  exit 1
fi

echo "=== ia-config — upgrade ==="
echo "Fonte: ${REPO_URL} (${REPO_BRANCH})"
echo

echo "Onde estão as instalações a atualizar (Cursor + Claude no projeto)?"
echo "  1) Global — ~/.cursor e ~/.claude (ou CLAUDE_CONFIG_DIR se já definido)"
echo "  2) Projeto — <projeto>/.cursor e <projeto>/.claude"
echo "     (Antigravity e Codex: sempre pastas globais.)"
echo
MODE="global"
read_tty -r -p "Escolha 1 ou 2 [1]: " in_mode || true
in_mode="${in_mode:-1}"
case "$in_mode" in
  1) MODE="global" ;;
  2) MODE="project" ;;
  *)
    echo "Opção inválida." >&2
    exit 1
    ;;
esac

PROJ=""
if [[ "$MODE" == "project" ]]; then
  while true; do
    read_tty -r -p "Caminho absoluto da raiz do projeto: " PROJ_RAW || true
    PROJ_RAW="${PROJ_RAW/#\~/$HOME}"
    if [[ -z "${PROJ_RAW:-}" ]]; then
      echo "Caminho obrigatório no modo projeto."
      continue
    fi
    if [[ ! -d "$PROJ_RAW" ]]; then
      echo "Pasta inexistente: $PROJ_RAW"
      continue
    fi
    PROJ="$(cd "$PROJ_RAW" && pwd)"
    break
  done
fi

echo
echo "Quais agentes atualizar?"
UP_CURSOR=false
UP_CLAUDE=false
UP_ANTI=false
UP_CODEX=false
prompt_yn "  Cursor?" "y" && UP_CURSOR=true
prompt_yn "  Claude Code?" "y" && UP_CLAUDE=true
prompt_yn "  Antigravity (Gemini)?" "y" && UP_ANTI=true
prompt_yn "  Codex (OpenAI)?" "y" && UP_CODEX=true

if [[ "$UP_CURSOR" != true && "$UP_CLAUDE" != true && "$UP_ANTI" != true && "$UP_CODEX" != true ]]; then
  echo "Nenhum agente selecionado. A sair." >&2
  exit 1
fi

NEED_PY=false
[[ "$UP_CLAUDE" == true || "$UP_ANTI" == true || "$UP_CODEX" == true ]] && NEED_PY=true
if [[ "$NEED_PY" == true ]] && ! command -v python3 >/dev/null 2>&1; then
  echo "Erro: python3 é necessário para Claude, Antigravity e Codex." >&2
  exit 1
fi

echo
if prompt_yn "Atualizar skills Caveman (clone upstream → skills/) onde o script aplicar?" "n"; then
  export INSTALL_CAVEMAN=yes
else
  export INSTALL_CAVEMAN=no
fi

TMP=""
cleanup() {
  if [[ -n "$TMP" && -d "$TMP" ]]; then
    rm -rf "$TMP"
  fi
}

trap cleanup EXIT
TMP="$(mktemp -d)"
CLONE_DIR="$TMP/ia-config"
echo
echo "A clonar (shallow) para pasta temporária..."
git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$CLONE_DIR"

export INSTALL_IA_SOURCE_ROOT="$CLONE_DIR"

if [[ "$MODE" == "project" ]]; then
  [[ "$UP_CURSOR" == true ]] && export CURSOR_HOME="${PROJ}/.cursor"
  [[ "$UP_CLAUDE" == true ]] && export CLAUDE_CONFIG_DIR="${PROJ}/.claude"
else
  [[ "$UP_CURSOR" == true ]] && export CURSOR_HOME="${HOME}/.cursor"
fi

run_block() {
  local title="$1"
  shift
  echo
  echo "---------- $title ----------"
  "$@"
}

# Cursor: instalação completa das pastas (espelha o repo; ficheiros novos aparecem; removidos no repo deixam de existir no destino).
[[ "$UP_CURSOR" == true ]] && run_block "Cursor" bash "$CLONE_DIR/install/cursor.sh" "${EXTRA_ARGS[@]}"

# Claude / Antigravity / Codex: fluxo --upgrade (Karpathy, Caveman conforme INSTALL_CAVEMAN, re-sync convertido).
[[ "$UP_CLAUDE" == true ]] && run_block "Claude Code" bash "$CLONE_DIR/install/claude.sh" --upgrade "${EXTRA_ARGS[@]}"
[[ "$UP_ANTI" == true ]] && run_block "Antigravity" bash "$CLONE_DIR/install/antigravity.sh" --upgrade "${EXTRA_ARGS[@]}"
[[ "$UP_CODEX" == true ]] && run_block "Codex" bash "$CLONE_DIR/install/codex.sh" --upgrade "${EXTRA_ARGS[@]}"

echo
echo "Upgrade concluído."
echo "(Pasta temporária do clone removida automaticamente.)"
