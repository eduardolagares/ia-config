#!/usr/bin/env bash
# Instalador interativo: clona eduardolagares/ia-config (main) para pasta temporária
# e copia ficheiros para Cursor / Claude / Antigravity / Codex.
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash -s -- --dry-run
set -euo pipefail

REPO_URL="https://github.com/eduardolagares/ia-config.git"
REPO_BRANCH="main"

# declare -a evita EXTRA_ARGS "unset" com set -u em bash antigo (ex.: macOS 3.2);
# índice explícito em vez de += para compatibilidade.
declare -a EXTRA_ARGS
for arg in "$@"; do
  case "$arg" in
    --dry-run) EXTRA_ARGS[${#EXTRA_ARGS[@]}]=--dry-run ;;
    -h | --help)
      echo "Uso: curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash"
      echo "     curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash -s -- --dry-run"
      echo "Clona ${REPO_URL} (${REPO_BRANCH}) para /tmp, pergunta destino (global vs projeto) e agentes, corre install/*.sh."
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
  echo "Erro: curl é necessário (baixar Karpathy SKILL.md nos scripts de cada agente)." >&2
  exit 1
fi

echo "=== ia-config — instalador ==="
echo "Fonte: ${REPO_URL} (${REPO_BRANCH})"
echo

echo "Onde instalar a parte que vive no projeto?"
echo "  1) Global — Cursor em ~/.cursor ; Claude em ~/.claude (ou CLAUDE_CONFIG_DIR se já definido)"
echo "  2) Projeto — Cursor em <projeto>/.cursor ; Claude em <projeto>/.claude"
echo "     (Antigravity e Codex usam sempre as pastas globais do utilizador.)"
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
echo "Quais agentes instalar?"
INST_CURSOR=false
INST_CLAUDE=false
INST_ANTI=false
INST_CODEX=false
prompt_yn "  Cursor?" "y" && INST_CURSOR=true
prompt_yn "  Claude Code?" "y" && INST_CLAUDE=true
prompt_yn "  Antigravity (Gemini)?" "y" && INST_ANTI=true
prompt_yn "  Codex (OpenAI)?" "y" && INST_CODEX=true

if [[ "$INST_CURSOR" != true && "$INST_CLAUDE" != true && "$INST_ANTI" != true && "$INST_CODEX" != true ]]; then
  echo "Nenhum agente selecionado. A sair." >&2
  exit 1
fi

NEED_PY=false
[[ "$INST_CLAUDE" == true || "$INST_ANTI" == true || "$INST_CODEX" == true ]] && NEED_PY=true
if [[ "$NEED_PY" == true ]] && ! command -v python3 >/dev/null 2>&1; then
  echo "Erro: python3 é necessário para Claude, Antigravity e Codex." >&2
  exit 1
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
  [[ "$INST_CURSOR" == true ]] && export CURSOR_HOME="${PROJ}/.cursor"
  [[ "$INST_CLAUDE" == true ]] && export CLAUDE_CONFIG_DIR="${PROJ}/.claude"
else
  [[ "$INST_CURSOR" == true ]] && export CURSOR_HOME="${HOME}/.cursor"
fi

run_agent() {
  local name="$1"
  local script="$2"
  echo
  echo "---------- $name ----------"
  if [[ "${EXTRA_ARGS+set}" == "set" ]] && ((${#EXTRA_ARGS[@]} > 0)); then
    bash "$CLONE_DIR/install/$script" "${EXTRA_ARGS[@]}"
  else
    bash "$CLONE_DIR/install/$script"
  fi
}

[[ "$INST_CURSOR" == true ]] && run_agent "Cursor" "cursor.sh"
[[ "$INST_CLAUDE" == true ]] && run_agent "Claude Code" "claude.sh"
[[ "$INST_ANTI" == true ]] && run_agent "Antigravity" "antigravity.sh"
[[ "$INST_CODEX" == true ]] && run_agent "Codex" "codex.sh"

echo
echo "Instalação concluída."
echo "(Pasta temporária do clone removida automaticamente.)"
