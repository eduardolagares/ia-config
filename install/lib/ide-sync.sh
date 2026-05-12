#!/usr/bin/env bash
# Sincroniza rules/commands/skills do repo ia-config para estruturas de IDE (não-Cursor).
# Requer python3 (install/lib/convert_ia_config.py).
IA_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IA_PYTHON="${IA_PYTHON:-python3}"

ia_config_require_python() {
  if ! command -v "$IA_PYTHON" >/dev/null 2>&1; then
    echo "Erro: $IA_PYTHON é necessário para converter rules e comandos (install/lib/convert_ia_config.py)." >&2
    return 1
  fi
}

ia_config_py() {
  "$IA_PYTHON" "$IA_LIB_DIR/convert_ia_config.py" "$@"
}

# Skills Codex geridas por comando: pastas command-<slug>. Comandos antigos usavam prefixo
# baladapp-; o repo passou a bld-. Remove órfãos command-baladapp-* antes de regenerar.
# Args: agents_skills_home, dry_run (true|false)
ia_config_remove_legacy_codex_command_skills() {
  local agents_skills="${1:?}"
  local dry="${2:?}"
  shopt -s nullglob
  local p
  for p in "$agents_skills"/command-baladapp-*; do
    [[ -e "$p" ]] || continue
    if [[ "$dry" == true ]]; then
      echo "[dry-run] rm -rf $p"
    else
      rm -rf "$p"
      echo "  (legado removido) $(basename "$p")"
    fi
  done
  shopt -u nullglob
}

# Args: repo_root, claude_home, dry_run (true|false)
ia_config_sync_claude_rules_and_commands() {
  local repo="$1" home="$2" dry="$3"
  ia_config_require_python || return 1
  echo "Claude Code: rules ( .mdc → .md, globs→paths ) e commands em $home/"
  if [[ "$dry" == true ]]; then
    echo "[dry-run] mkdir -p $home/rules $home/commands"
    shopt -s nullglob
    for f in "$repo/rules"/*.mdc; do
      echo "[dry-run] rule-to-md $f → $home/rules/$(basename "$f" .mdc).md"
    done
    for f in "$repo/commands"/*.md; do
      echo "[dry-run] command-copy $f → $home/commands/$(basename "$f") (mode claude)"
    done
    shopt -u nullglob
    return 0
  fi
  mkdir -p "$home/rules" "$home/commands"
  if [[ -e "$home/rules" && ! -d "$home/rules" ]]; then
    rm -rf "$home/rules"
    mkdir -p "$home/rules"
  fi
  if [[ -L "$home/rules" ]]; then
    rm -f "$home/rules"
    mkdir -p "$home/rules"
  fi
  if [[ -L "$home/commands" ]]; then
    rm -f "$home/commands"
    mkdir -p "$home/commands"
  fi
  rm -rf "$home/rules"/*
  rm -rf "$home/commands"/*
  shopt -s nullglob
  local f base
  for f in "$repo/rules"/*.mdc; do
    base=$(basename "$f" .mdc)
    ia_config_py rule-to-md "$f" "$home/rules/${base}.md"
    echo "  rules/${base}.md"
  done
  for f in "$repo/commands"/*.md; do
    ia_config_py command-copy "$f" "$home/commands/$(basename "$f")" claude
    echo "  commands/$(basename "$f")"
  done
  shopt -u nullglob
}

# Args: repo_root, claude_home, dry_run
ia_config_sync_claude_skills() {
  local repo="$1" home="$2" dry="$3"
  ia_config_require_python || return 1
  echo "Claude Code: skills (pastas com SKILL.md) → $home/skills/"
  if [[ "$dry" == true ]]; then
    echo "[dry-run] sync-skill-trees $repo/skills → $home/skills"
    return 0
  fi
  mkdir -p "$home/skills"
  if [[ -L "$home/skills" ]]; then
    rm -f "$home/skills"
    mkdir -p "$home/skills"
  fi
  # não apagar skills de terceiros colocados manualmente: só substituir nomes que existem no repo
  shopt -s nullglob
  local d
  for d in "$repo/skills"/*; do
    [[ -d "$d" ]] || continue
    [[ -f "$d/SKILL.md" ]] || continue
    local name
    name=$(basename "$d")
    if [[ -e "$home/skills/$name" ]]; then
      rm -rf "$home/skills/$name"
    fi
    cp -R "$d" "$home/skills/"
    echo "  skills/$name"
  done
  shopt -u nullglob
}

# Args: repo_root, gemini_home, dry_run
ia_config_sync_antigravity_rules_workflows() {
  local repo="$1" gem="$2" dry="$3"
  ia_config_require_python || return 1
  local rules_dest workflows_dest
  rules_dest="$gem/antigravity/ia-config/rules"
  workflows_dest="$gem/antigravity/global_workflows"
  echo "Antigravity: rules → $rules_dest/ ; workflows (commands) → $workflows_dest/"
  if [[ "$dry" == true ]]; then
    echo "[dry-run] mkdir -p $rules_dest $workflows_dest"
    shopt -s nullglob
    for f in "$repo/rules"/*.mdc; do
      echo "[dry-run] rule-to-md $f → $rules_dest/$(basename "$f" .mdc).md"
    done
    for f in "$repo/commands"/*.md; do
      echo "[dry-run] command-copy $f → $workflows_dest/$(basename "$f") (antigravity)"
    done
    shopt -u nullglob
    return 0
  fi
  mkdir -p "$rules_dest" "$workflows_dest"
  rm -rf "$rules_dest"/*
  rm -rf "$workflows_dest"/*
  shopt -s nullglob
  local f base
  for f in "$repo/rules"/*.mdc; do
    base=$(basename "$f" .mdc)
    ia_config_py rule-to-md "$f" "$rules_dest/${base}.md"
    echo "  ia-config/rules/${base}.md"
  done
  for f in "$repo/commands"/*.md; do
    ia_config_py command-copy "$f" "$workflows_dest/$(basename "$f")" antigravity
    echo "  global_workflows/$(basename "$f")"
  done
  shopt -u nullglob
}

# Args: repo_root, gemini_home, dry_run
ia_config_sync_antigravity_skills() {
  local repo="$1" gem="$2" dry="$3"
  ia_config_require_python || return 1
  local dest
  dest="$gem/antigravity/skills"
  echo "Antigravity: skills → $dest/"
  if [[ "$dry" == true ]]; then
    echo "[dry-run] sync-skill-trees $repo/skills → $dest"
    return 0
  fi
  mkdir -p "$dest"
  shopt -s nullglob
  local d name
  for d in "$repo/skills"/*; do
    [[ -d "$d" ]] || continue
    [[ -f "$d/SKILL.md" ]] || continue
    name=$(basename "$d")
    if [[ -e "$dest/$name" ]]; then
      rm -rf "$dest/$name"
    fi
    cp -R "$d" "$dest/"
    echo "  skills/$name"
  done
  shopt -u nullglob
}

# Args: repo_root, agents_skills_home (ex.: $HOME/.agents/skills), dry_run
ia_config_sync_codex_managed_skills() {
  local repo="$1" agents_skills="$2" dry="$3"
  ia_config_require_python || return 1
  echo "Codex: skills globais em $agents_skills (rules + commands + repo/skills)"
  if [[ "$dry" == true ]]; then
    echo "[dry-run] mkdir -p $agents_skills"
    echo "[dry-run] remover skills Codex command-baladapp-* (comandos renomeados para bld-)"
    ia_config_remove_legacy_codex_command_skills "$agents_skills" true
    echo "[dry-run] apagar ia-rule-* e command-* geridos; regenerar skills; copiar pastas com SKILL.md de $repo/skills"
    return 0
  fi
  mkdir -p "$agents_skills"
  mkdir -p "$agents_skills/ia-tdd-markdown"
  ia_config_remove_legacy_codex_command_skills "$agents_skills" false
  shopt -s nullglob
  local f
  for f in "$repo/commands"/*.md; do
    rm -rf "$agents_skills/command-$(basename "$f" .md)"
  done
  for f in "$repo/rules"/*.mdc; do
    rm -rf "$agents_skills/ia-rule-$(basename "$f" .mdc)"
  done
  for f in "$repo/commands"/*.md; do
    ia_config_py command-to-codex-skill "$f" "$agents_skills"
    echo "  command-$(basename "$f" .md)/SKILL.md"
  done
  for f in "$repo/rules"/*.mdc; do
    ia_config_py rule-to-codex-skill "$f" "$agents_skills"
    echo "  ia-rule-$(basename "$f" .mdc)/SKILL.md"
  done
  for d in "$repo/skills"/*; do
    [[ -d "$d" ]] || continue
    [[ -f "$d/SKILL.md" ]] || continue
    local name
    name=$(basename "$d")
    if [[ -e "$agents_skills/$name" ]]; then
      rm -rf "$agents_skills/$name"
    fi
    cp -R "$d" "$agents_skills/"
    echo "  $name/ (repo skills)"
  done
  shopt -u nullglob
}
