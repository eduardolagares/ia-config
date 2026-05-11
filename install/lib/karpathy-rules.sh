#!/usr/bin/env bash
# Descarga obrigatória de rules/karpathy-guidelines.mdc a partir do upstream
# https://github.com/forrestchang/andrej-karpathy-skills

# URL raw do ficheiro no repo upstream (override com KARPATHY_GUIDELINES_URL).
KARPATHY_GUIDELINES_URL_DEFAULT="https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/.cursor/rules/karpathy-guidelines.mdc"

install_karpathy_guidelines() {
  local repo_root="$1"
  local dry_run="$2"
  local url="${KARPATHY_GUIDELINES_URL:-$KARPATHY_GUIDELINES_URL_DEFAULT}"
  local dest="$repo_root/rules/karpathy-guidelines.mdc"

  echo "Karpathy guidelines (obrigatório — fonte: github.com/forrestchang/andrej-karpathy-skills):"

  if [[ "$dry_run" == true ]]; then
    echo "[dry-run] Descarregaria $dest a partir de $url"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "Erro: curl é necessário para obter karpathy-guidelines.mdc do upstream." >&2
    return 1
  fi

  mkdir -p "$repo_root/rules"
  curl -fsSL -o "$dest" "$url"
  echo "  $dest OK"
}
