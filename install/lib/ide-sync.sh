#!/usr/bin/env bash
# Sincroniza rules/eduardolagares e skills/eduardolagares do repo ia-config para Cursor ou ~/.agents.
IA_NAMESPACE="eduardolagares"

# Skills substituídas por revisar-tarefa (layouts flat e namespace).
IA_CONFIG_OBSOLETE_SKILLS=(
  agendar-revisao-tarefa
  executar-revisao-tarefa
)

ia_config_each_rule_mdc() {
  local repo="$1"
  local rules_ns="$repo/rules/$IA_NAMESPACE"
  [[ -d "$rules_ns" ]] || return 0
  local f
  while IFS= read -r -d '' f; do
    printf '%s\0' "$f"
  done < <(find "$rules_ns" -name '*.mdc' -print0 | sort -z)
}

ia_config_remove_legacy_install_artifacts() {
  local home="$1"
  local dry="$2"
  local agents_skills="${3:-}"

  local remove_item
  remove_item() {
    local p="$1"
    [[ -e "$p" || -L "$p" ]] || return 0
    if [[ "$dry" == true ]]; then
      echo "[dry-run] rm -rf $p"
    else
      rm -rf "$p"
      echo "  (legado removido) $p"
    fi
  }

  remove_item "$home/commands"

  shopt -s nullglob
  local f p name
  if [[ -n "$agents_skills" && -d "$agents_skills" ]]; then
    for p in "$agents_skills"/command-* "$agents_skills"/ia-rule-*; do
      [[ -e "$p" ]] || continue
      remove_item "$p"
    done
  fi

  if [[ -d "$home/rules" ]]; then
    for f in "$home/rules"/baladapp-*.mdc "$home/rules"/baladapp-*.md; do
      remove_item "$f"
    done
    for f in "$home/rules/$IA_NAMESPACE"/baladapp-*.mdc; do
      remove_item "$f"
    done
    # Karpathy na raiz de rules/ (layout antigo); o activo fica em rules/eduardolagares/
    remove_item "$home/rules/karpathy-guidelines.mdc"
    remove_item "$home/rules/karpathy-guidelines.md"
  fi

  if [[ -d "$home/skills" ]]; then
    for name in "${IA_CONFIG_OBSOLETE_SKILLS[@]}"; do
      remove_item "$home/skills/$name"
      remove_item "$home/skills/$IA_NAMESPACE/$name"
    done
    # Skills em layout flat (pré-namespace eduardolagares)
    for p in "$home/skills"/revisar-tarefa \
      "$home/skills"/comitar "$home/skills"/tdd-dev "$home/skills"/tdd-doc \
      "$home/skills"/code-review "$home/skills"/README.md; do
      remove_item "$p"
    done
  fi
  shopt -u nullglob
}

ia_config_sync_rules_mdc_tree() {
  local repo="$1" dest_rules="$2" dry="$3"
  local src_ns="$repo/rules/$IA_NAMESPACE"
  local dest_ns="$dest_rules/$IA_NAMESPACE"
  echo "Rules (.mdc) → $dest_ns/"
  if [[ ! -d "$src_ns" ]]; then
    echo "AVISO: pasta inexistente no repo: $src_ns" >&2
    return 0
  fi
  if [[ "$dry" == true ]]; then
    ia_config_each_rule_mdc "$repo" | while IFS= read -r -d '' f; do
      local rel="${f#"$src_ns/"}"
      echo "[dry-run] cp $f → $dest_ns/$rel"
    done
    return 0
  fi
  mkdir -p "$dest_rules"
  rm -rf "$dest_ns"
  local f rel dest_dir
  while IFS= read -r -d '' f; do
    rel="${f#"$src_ns/"}"
    dest_dir="$dest_ns/$(dirname "$rel")"
    mkdir -p "$dest_dir"
    cp "$f" "$dest_ns/$rel"
    echo "  rules/$IA_NAMESPACE/$rel"
  done < <(ia_config_each_rule_mdc "$repo")
}

ia_config_sync_eduardolagares_skills() {
  local repo="$1" dest_skills="$2" dry="$3"
  local src="$repo/skills/$IA_NAMESPACE"
  local dest="$dest_skills/$IA_NAMESPACE"
  echo "Skills → $dest/"
  if [[ ! -d "$src" ]]; then
    echo "AVISO: pasta inexistente no repo: $src" >&2
    return 0
  fi
  if [[ "$dry" == true ]]; then
    echo "[dry-run] rm -rf $dest && cp -R $src $dest_skills/"
    return 0
  fi
  mkdir -p "$dest_skills"
  rm -rf "$dest"
  cp -R "$src" "$dest_skills/"
  echo "  skills/$IA_NAMESPACE/ (cópia de $src)"
}

ia_config_print_sync_summary() {
  local dest_rules="$1" dest_skills="$2"
  local rules_ns="$dest_rules/$IA_NAMESPACE"
  local skills_ns="$dest_skills/$IA_NAMESPACE"

  echo
  echo "Resumo do sync ($IA_NAMESPACE):"
  if [[ -d "$rules_ns" ]]; then
    local n always karpathy
    n="$(find "$rules_ns" -name '*.mdc' | wc -l | tr -d ' ')"
    always="$(grep -l 'alwaysApply: true' "$rules_ns"/*.mdc 2>/dev/null | xargs -I{} basename {} | paste -sd ', ' - || true)"
    echo "  Rules: ${n} ficheiros .mdc"
    [[ -n "$always" ]] && echo "    alwaysApply: ${always}"
    [[ -f "$rules_ns/karpathy-guidelines.mdc" ]] || echo "    AVISO: karpathy-guidelines.mdc ausente (correr install de novo)"
  fi
  if [[ -d "$skills_ns/revisar-tarefa" ]]; then
    echo "  Skill revisar-tarefa: instalada (substitui agendar-revisao-tarefa + executar-revisao-tarefa)"
  fi
  if [[ -d "$skills_ns/escrever-tarefa" ]]; then
    echo "  Skill escrever-tarefa: instalada (docs/tarefas/; grill-me em ~/.agents, ~/.cursor ou ~/.claude)"
  fi
  if [[ -d "$skills_ns/refatorar-codigo" ]]; then
    echo "  Skill refatorar-codigo: instalada (/refatorar-codigo — refatora diff vs master ou alterações locais)"
  fi
}

ia_config_sync_cursor_home() {
  local repo="$1" cursor_home="$2" dry="$3"
  echo "Cursor: sync $IA_NAMESPACE em $cursor_home/"
  ia_config_remove_legacy_install_artifacts "$cursor_home" "$dry"
  ia_config_sync_rules_mdc_tree "$repo" "$cursor_home/rules" "$dry"
  ia_config_sync_eduardolagares_skills "$repo" "$cursor_home/skills" "$dry"
}

ia_config_sync_agents_home() {
  local repo="$1" agents_home="$2" dry="$3"
  echo "Agents: sync $IA_NAMESPACE em $agents_home/"
  ia_config_remove_legacy_install_artifacts "$agents_home" "$dry" "$agents_home/skills"
  ia_config_sync_rules_mdc_tree "$repo" "$agents_home/rules" "$dry"
  ia_config_sync_eduardolagares_skills "$repo" "$agents_home/skills" "$dry"
}
