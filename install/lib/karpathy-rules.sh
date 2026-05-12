#!/usr/bin/env bash
# Baixa o Karpathy sempre do SKILL.md upstream (nada disso fica versionado neste repo).
# Fonte padrão: https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md
#
# Override: KARPATHY_GUIDELINES_URL — URL raw alternativa do mesmo formato (frontmatter + corpo).

_KARPATHY_RULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

KARPATHY_GUIDELINES_URL_DEFAULT="https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/skills/karpathy-guidelines/SKILL.md"

install_karpathy_guidelines() {
  local repo_root="$1"
  local dry_run="$2"
  local for_upgrade="${3:-false}"
  local url="${KARPATHY_GUIDELINES_URL:-$KARPATHY_GUIDELINES_URL_DEFAULT}"
  local dest="$repo_root/rules/karpathy-guidelines.mdc"
  local tmp

  if [[ "$for_upgrade" == true ]]; then
    echo "Karpathy guidelines (upgrade — fonte: skills/karpathy-guidelines/SKILL.md no andrej-karpathy-skills):"
  else
    echo "Karpathy guidelines (obrigatório — fonte: skills/karpathy-guidelines/SKILL.md no andrej-karpathy-skills):"
  fi

  if [[ "$dry_run" == true ]]; then
    echo "[dry-run] Baixaria $url → converteria com python3 → $dest"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "Erro: curl é necessário para baixar o SKILL.md do Karpathy no upstream." >&2
    return 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "Erro: python3 é necessário para converter o SKILL.md do Karpathy em rules/karpathy-guidelines.mdc." >&2
    return 1
  fi

  tmp="$(mktemp "${TMPDIR:-/tmp}/karpathy-skill.XXXXXX")"
  # shellcheck disable=SC2064
  trap "rm -f \"$tmp\"" EXIT

  mkdir -p "$repo_root/rules"
  curl -fsSL -o "$tmp" "$url"
  python3 "$_KARPATHY_RULES_DIR/convert_ia_config.py" karpathy-skill-to-mdc "$tmp" "$dest"
  trap - EXIT
  rm -f "$tmp"

  echo "  $dest OK (a partir de $url)"
}
