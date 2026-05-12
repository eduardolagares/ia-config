#!/usr/bin/env bash
# Instalador interativo: clona ia-config para pasta temporária e copia ficheiros
# para Cursor / Claude / Antigravity / Codex (sem depender de clone local prévio).
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash
#   bash install/install.sh [--dry-run]
#
# Variáveis:
#   IA_CONFIG_REPO_URL   URL git (predef.: repo público eduardolagares/ia-config)
#   IA_CONFIG_BRANCH     ramo (predef.: main)
#   IA_CONFIG_SKIP_CLONE=1  IA_CONFIG_REPO_ROOT=/caminho/existente  — só para desenvolvimento
set -euo pipefail

DEFAULT_REPO_URL="${IA_CONFIG_REPO_URL:-https://github.com/eduardolagares/ia-config.git}"
DEFAULT_BRANCH="${IA_CONFIG_BRANCH:-main}"

EXTRA_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) EXTRA_ARGS+=(--dry-run) ;;
    -h | --help)
      echo "Uso: bash install/install.sh [--dry-run]"
      echo "Pergunta: destino (global vs projeto), agentes; clona repo para /tmp e corre install/*.sh."
      echo "IA_CONFIG_REPO_URL, IA_CONFIG_BRANCH, IA_CONFIG_SKIP_CLONE, IA_CONFIG_REPO_ROOT — ver cabeçalho do script."
      exit 0
      ;;
    *)
      echo "Argumento desconhecido: $arg (usa --help)" >&2
      exit 1
      ;;
  esac
done

read_tty() {
  # /dev/tty pode falhar (CI, sandbox, pipe); nesse caso lê de stdin.
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
  echo "Erro: curl é necessário (Karpathy guidelines nos scripts de cada agente)." >&2
  exit 1
fi

echo "=== ia-config — instalador ==="
echo

REPO_URL="$DEFAULT_REPO_URL"
REPO_BRANCH="$DEFAULT_BRANCH"
read_tty -r -p "URL do repositório git [${REPO_URL}]: " in_url || true
[[ -n "${in_url:-}" ]] && REPO_URL="$in_url"

read_tty -r -p "Ramo [${REPO_BRANCH}]: " in_br || true
[[ -n "${in_br:-}" ]] && REPO_BRANCH="$in_br"

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

CLONE_DIR=""
if [[ "${IA_CONFIG_SKIP_CLONE:-}" == "1" ]]; then
  CLONE_DIR="${IA_CONFIG_REPO_ROOT:?Com IA_CONFIG_SKIP_CLONE=1 é obrigatório IA_CONFIG_REPO_ROOT.}"
  if [[ ! -f "$CLONE_DIR/install/cursor.sh" ]]; then
    echo "Erro: IA_CONFIG_REPO_ROOT não parece raiz do ia-config (falta install/cursor.sh)." >&2
    exit 1
  fi
else
  trap cleanup EXIT
  TMP="$(mktemp -d)"
  CLONE_DIR="$TMP/ia-config"
  echo
  echo "A clonar (shallow) para pasta temporária..."
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$CLONE_DIR"
fi

export IA_CONFIG_REPO_ROOT="$CLONE_DIR"

if [[ "$MODE" == "project" ]]; then
  [[ "$INST_CURSOR" == true ]] && export CURSOR_HOME="${PROJ}/.cursor"
  [[ "$INST_CLAUDE" == true ]] && export CLAUDE_CONFIG_DIR="${PROJ}/.claude"
else
  [[ "$INST_CURSOR" == true ]] && export CURSOR_HOME="${HOME}/.cursor"
  # Claude em modo global: não exportar CLAUDE_CONFIG_DIR (respeita env do utilizador ou ~/.claude).
fi

run_agent() {
  local name="$1"
  local script="$2"
  echo
  echo "---------- $name ----------"
  bash "$CLONE_DIR/install/$script" "${EXTRA_ARGS[@]}"
}

[[ "$INST_CURSOR" == true ]] && run_agent "Cursor" "cursor.sh"
[[ "$INST_CLAUDE" == true ]] && run_agent "Claude Code" "claude.sh"
[[ "$INST_ANTI" == true ]] && run_agent "Antigravity" "antigravity.sh"
[[ "$INST_CODEX" == true ]] && run_agent "Codex" "codex.sh"

echo
echo "Instalação concluída."
if [[ -n "$TMP" ]]; then
  echo "(Pasta temporária do clone removida automaticamente.)"
fi
