#!/usr/bin/env bash
# Instalador interativo: clona eduardolagares/ia-config (main) para pasta temporária
# e copia rules/skills eduardolagares para Cursor e/ou ~/.agents.
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash -s -- --dry-run
set -euo pipefail

REPO_URL="https://github.com/eduardolagares/ia-config.git"
REPO_BRANCH="main"

declare -a EXTRA_ARGS
for arg in "$@"; do
  case "$arg" in
    --dry-run) EXTRA_ARGS[${#EXTRA_ARGS[@]}]=--dry-run ;;
    -h | --help)
      echo "Uso: curl -fsSL …/install/install.sh | bash"
      echo "Clona ${REPO_URL} (${REPO_BRANCH}) para /tmp; pergunta destino (Cursor ou .agents)."
      echo "Estrutura: rules/eduardolagares/*.mdc (always: domain-layer, ruby; karpathy gerado)"
      echo "           skills/eduardolagares/*/SKILL.md (monday-task-info, revisar-tarefa, gitlab-api, tdd-doc, …)"
      echo "           Cursor: hook prefetch diff em \$CURSOR_HOME/hooks/"
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
  echo "Erro: curl é necessário (Karpathy SKILL.md)." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "Erro: python3 é necessário (conversão Karpathy → .mdc)." >&2
  exit 1
fi

echo "=== ia-config — instalador ==="
echo "Fonte: ${REPO_URL} (${REPO_BRANCH})"
echo

echo "Onde instalar rules/skills eduardolagares?"
echo "  1) Global — ~/.cursor"
echo "  2) Projeto — <projeto>/.cursor"
echo "  3) Global — ~/.agents"
echo "  4) Projeto — <projeto>/.agents"
echo
DEST_MODE="cursor_global"
read_tty -r -p "Escolha 1–4 [1]: " in_dest || true
in_dest="${in_dest:-1}"
case "$in_dest" in
  1) DEST_MODE="cursor_global" ;;
  2) DEST_MODE="cursor_project" ;;
  3) DEST_MODE="agents_global" ;;
  4) DEST_MODE="agents_project" ;;
  *)
    echo "Opção inválida." >&2
    exit 1
    ;;
esac

PROJ=""
if [[ "$DEST_MODE" == "cursor_project" || "$DEST_MODE" == "agents_project" ]]; then
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
INST_CURSOR=false
INST_AGENTS=false

if [[ "$DEST_MODE" == "agents_global" || "$DEST_MODE" == "agents_project" ]]; then
  INST_AGENTS=true
  echo "Destino .agents — sync eduardolagares activado."
else
  prompt_yn "Instalar no Cursor?" "y" && INST_CURSOR=true
  if [[ "$DEST_MODE" == "cursor_project" ]]; then
    prompt_yn "Instalar também em <projeto>/.agents?" "n" && INST_AGENTS=true
  else
    prompt_yn "Instalar também em ~/.agents?" "n" && INST_AGENTS=true
  fi
  if [[ "$DEST_MODE" == "cursor_project" && "$INST_AGENTS" == true ]]; then
    export AGENTS_HOME="${PROJ}/.agents"
  elif [[ "$INST_AGENTS" == true ]]; then
    export AGENTS_HOME="${HOME}/.agents"
  fi
fi

if [[ "$INST_CURSOR" != true && "$INST_AGENTS" != true ]]; then
  echo "Nenhum destino seleccionado. A sair." >&2
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

case "$DEST_MODE" in
  cursor_global)
    [[ "$INST_CURSOR" == true ]] && export CURSOR_HOME="${HOME}/.cursor"
    ;;
  cursor_project)
    [[ "$INST_CURSOR" == true ]] && export CURSOR_HOME="${PROJ}/.cursor"
    ;;
  agents_global)
    export AGENTS_HOME="${HOME}/.agents"
    ;;
  agents_project)
    export AGENTS_HOME="${PROJ}/.agents"
    ;;
esac

run_agent() {
  local name="$1"
  local script="$2"
  echo
  echo "---------- $name ----------"
  if ((${#EXTRA_ARGS[@]} > 0)); then
    bash "$CLONE_DIR/install/$script" "${EXTRA_ARGS[@]}"
  else
    bash "$CLONE_DIR/install/$script"
  fi
}

[[ "$INST_CURSOR" == true ]] && run_agent "Cursor" "cursor.sh"
[[ "$INST_AGENTS" == true ]] && run_agent "Agents (.agents)" "agents.sh"

echo
echo "Instalação concluída."
echo "(Pasta temporária do clone removida automaticamente.)"
