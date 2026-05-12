#!/usr/bin/env python3
"""
Conversões na instalação: rules .mdc (Cursor) → .md compatível Claude / Antigravity;
comandos → cópia com reescrita de paths; comandos → skill Codex (.agents/skills);
Karpathy SKILL.md upstream → rules/karpathy-guidelines.mdc.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
from pathlib import Path


def read_ia_config_version(repo_root: Path) -> str:
    """Lê a primeira linha de VERSION na raiz do repositório (semver do pacote de conteúdo)."""
    p = repo_root / "VERSION"
    if not p.is_file():
        return "0.0.0"
    raw = p.read_text(encoding="utf-8").strip()
    if not raw:
        return "0.0.0"
    return raw.splitlines()[0].strip() or "0.0.0"


def split_frontmatter(text: str) -> tuple[str | None, str]:
    if not text.startswith("---"):
        return None, text
    # First line must be --- only
    first_nl = text.find("\n", 0)
    if first_nl == -1 or text[:first_nl].strip() != "---":
        return None, text
    rest = text[first_nl + 1 :]
    end = rest.find("\n---")
    if end == -1:
        return None, text
    # end points to start of closing ---; consume optional trailing newline
    fm = rest[:end]
    after = rest[end:]
    # after begins with \n--- possibly \n
    close_len = after.find("\n", 1)
    if close_len == -1:
        body = ""
    else:
        body = after[close_len + 1 :]
    return fm, body


def convert_rule_frontmatter_to_claude(fm: str) -> str:
    """Cursor: globs, alwaysApply. Claude Code: paths; sem alwaysApply."""
    always_apply = False
    globs_val: str | None = None
    kept: list[str] = []
    for line in fm.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if re.match(r"^alwaysApply\s*:", stripped, re.I):
            v = stripped.split(":", 1)[1].strip().lower()
            always_apply = v in ("true", "yes", "1")
            continue
        if re.match(r"^globs\s*:", stripped, re.I):
            globs_val = stripped.split(":", 1)[1].strip()
            continue
        kept.append(line)
    out_lines = kept.copy()
    if not always_apply and globs_val:
        out_lines.append(f"paths: {globs_val}")
    return "\n".join(out_lines).strip() + ("\n" if out_lines else "")


def rule_to_claude_md(src: Path, dst: Path) -> None:
    raw = src.read_text(encoding="utf-8")
    fm, body = split_frontmatter(raw)
    dst.parent.mkdir(parents=True, exist_ok=True)
    if fm is None:
        dst.write_text(raw, encoding="utf-8")
        return
    new_fm = convert_rule_frontmatter_to_claude(fm)
    if not new_fm.strip():
        dst.write_text(body, encoding="utf-8")
    else:
        dst.write_text(f"---\n{new_fm}---\n{body}", encoding="utf-8")


def rule_to_plain_md(src: Path, dst: Path) -> None:
    """Antigravity / cópia genérica: mesmo ajuste de frontmatter que Claude (paths, sem alwaysApply)."""
    rule_to_claude_md(src, dst)


def karpathy_skill_to_mdc(src: Path, dst: Path) -> None:
    """Upstream SKILL.md (name/description) → rules/karpathy-guidelines.mdc (Cursor + resto do pipeline)."""
    raw = src.read_text(encoding="utf-8")
    meta, body = _parse_simple_frontmatter(raw)
    desc = meta.get(
        "description",
        "Diretrizes comportamentais para reduzir erros comuns em código com LLM.",
    )
    body = body.lstrip("\n")
    repo_root = dst.parent.parent
    ver = os.environ.get("IA_CONFIG_CONTENT_VERSION", "").strip() or read_ia_config_version(repo_root)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(
        f"---\ndescription: {json.dumps(desc)}\nbaladapp_ia_config_version: {json.dumps(ver)}\nalwaysApply: true\n---\n\n{body}",
        encoding="utf-8",
    )


_PATH_REPLACEMENTS = {
    "claude": [
        ("~/.cursor/commands/skills/", "~/.claude/commands/skills/"),
        ("${HOME}/.cursor/commands/skills/", "${HOME}/.claude/commands/skills/"),
        ("~/.cursor/commands/", "~/.claude/commands/"),
        ("${HOME}/.cursor/commands/", "${HOME}/.claude/commands/"),
    ],
    "antigravity": [
        ("~/.cursor/commands/skills/", "~/.gemini/antigravity/global_workflows/skills/"),
        ("${HOME}/.cursor/commands/skills/", "${HOME}/.gemini/antigravity/global_workflows/skills/"),
        ("~/.cursor/commands/", "~/.gemini/antigravity/global_workflows/"),
        ("${HOME}/.cursor/commands/", "${HOME}/.gemini/antigravity/global_workflows/"),
    ],
    "codex": [
        (
            "~/.cursor/commands/skills/",
            "~/.agents/skills/ia-tdd-markdown/",
        ),
        (
            "${HOME}/.cursor/commands/skills/",
            "${HOME}/.agents/skills/ia-tdd-markdown/",
        ),
        ("~/.cursor/commands/", "~/.agents/skills/command-"),
        ("${HOME}/.cursor/commands/", "${HOME}/.agents/skills/command-"),
    ],
}


def rewrite_paths_markdown(text: str, mode: str) -> str:
    for old, new in _PATH_REPLACEMENTS.get(mode, []):
        text = text.replace(old, new)
    if mode == "codex":
        # ~/.agents/skills/command-baladapp-tdd-doc.md → folder command-baladapp-tdd-doc/SKILL.md
        text = re.sub(
            r"(~/.agents/skills/command-)([a-z0-9_-]+)\.md",
            r"\1\2/SKILL.md",
            text,
            flags=re.I,
        )
        text = re.sub(
            r"(\$\{HOME\}/\.agents/skills/command-)([a-z0-9_-]+)\.md",
            r"\1\2/SKILL.md",
            text,
            flags=re.I,
        )
    return text


def command_copy(src: Path, dst: Path, mode: str) -> None:
    raw = src.read_text(encoding="utf-8")
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(rewrite_paths_markdown(raw, mode), encoding="utf-8")


def _parse_simple_frontmatter(text: str) -> tuple[dict[str, str], str]:
    fm, body = split_frontmatter(text)
    if fm is None:
        return {}, text
    meta: dict[str, str] = {}
    for line in fm.splitlines():
        if ":" not in line:
            continue
        k, v = line.split(":", 1)
        meta[k.strip()] = v.strip().strip('"').strip("'")
    return meta, body


def command_to_codex_skill(src: Path, dest_skill_dir: Path) -> None:
    """commands/foo.md → .agents/skills/command-foo/SKILL.md com name + description."""
    slug = src.stem
    folder_name = f"command-{slug}"
    skill_dir = dest_skill_dir / folder_name
    raw = src.read_text(encoding="utf-8")
    meta, body = _parse_simple_frontmatter(raw)
    desc = meta.get("description", f"Slash-style workflow `{slug}`. Use when the user invokes /{slug} or matching task.")
    name = meta.get("name", folder_name)
    body = rewrite_paths_markdown(body, "codex")
    skill_dir.mkdir(parents=True, exist_ok=True)
    skill_md = skill_dir / "SKILL.md"
    ver = read_ia_config_version(src.parent.parent)
    skill_md.write_text(
        f"---\nname: {json.dumps(name)}\ndescription: {json.dumps(desc)}\nbaladapp_ia_config_version: {json.dumps(ver)}\n---\n{body}",
        encoding="utf-8",
    )


def rule_to_codex_skill(src: Path, dest_skill_dir: Path) -> None:
    """rules/<nome>.mdc → .agents/skills/ia-rule-<nome>/SKILL.md (ex.: baladapp-*.mdc ou terceiros sem prefixo)."""
    slug = src.stem
    folder_name = f"ia-rule-{slug}"
    skill_dir = dest_skill_dir / folder_name
    raw = src.read_text(encoding="utf-8")
    fm, body = split_frontmatter(raw)
    skill_dir.mkdir(parents=True, exist_ok=True)
    desc = "Rails / ia-config team rule."
    scope_note = ""
    if fm:
        for line in fm.splitlines():
            if line.strip().lower().startswith("description:"):
                desc = line.split(":", 1)[1].strip().strip('"').strip("'")
                break
        new_fm = convert_rule_frontmatter_to_claude(fm).strip()
        if new_fm:
            scope_note = f"## Path scopes (from ia-config)\n\n```yaml\n{new_fm}\n```\n\n"
    intro = (
        f"# Rule: {slug}\n\n"
        f"Convention pack from ia-config (`{src.name}`). "
        "Follow when the task matches the description and scopes.\n\n"
    )
    skill_md = skill_dir / "SKILL.md"
    ver = read_ia_config_version(src.parent.parent)
    skill_md.write_text(
        f"---\nname: {json.dumps(folder_name)}\ndescription: {json.dumps(desc)}\nbaladapp_ia_config_version: {json.dumps(ver)}\n---\n{intro}{scope_note}{body.lstrip()}",
        encoding="utf-8",
    )


def sync_skill_trees(src_root: Path, dest_root: Path) -> None:
    """Copia cada subpasta de src_root que contém SKILL.md para dest_root."""
    if not src_root.is_dir():
        return
    dest_root.mkdir(parents=True, exist_ok=True)
    for child in src_root.iterdir():
        if not child.is_dir():
            continue
        if not (child / "SKILL.md").is_file():
            continue
        target = dest_root / child.name
        if target.exists():
            shutil.rmtree(target)
        shutil.copytree(child, target)


def main() -> int:
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)

    p1 = sub.add_parser("rule-to-md")
    p1.add_argument("src", type=Path)
    p1.add_argument("dst", type=Path)

    p2 = sub.add_parser("command-copy")
    p2.add_argument("src", type=Path)
    p2.add_argument("dst", type=Path)
    p2.add_argument("mode", choices=["claude", "antigravity", "codex"])

    p3 = sub.add_parser("command-to-codex-skill")
    p3.add_argument("src", type=Path)
    p3.add_argument("dest_skills_root", type=Path)

    p4 = sub.add_parser("rule-to-codex-skill")
    p4.add_argument("src", type=Path)
    p4.add_argument("dest_skills_root", type=Path)

    p5 = sub.add_parser("sync-skill-trees")
    p5.add_argument("src_skills_root", type=Path)
    p5.add_argument("dest_skills_root", type=Path)

    p6 = sub.add_parser("karpathy-skill-to-mdc")
    p6.add_argument("src", type=Path)
    p6.add_argument("dst", type=Path)

    args = p.parse_args()
    if args.cmd == "rule-to-md":
        rule_to_plain_md(args.src, args.dst)
    elif args.cmd == "command-copy":
        command_copy(args.src, args.dst, args.mode)
    elif args.cmd == "command-to-codex-skill":
        command_to_codex_skill(args.src, args.dest_skills_root)
    elif args.cmd == "rule-to-codex-skill":
        rule_to_codex_skill(args.src, args.dest_skills_root)
    elif args.cmd == "sync-skill-trees":
        sync_skill_trees(args.src_skills_root, args.dest_skills_root)
    elif args.cmd == "karpathy-skill-to-mdc":
        karpathy_skill_to_mdc(args.src, args.dst)
    return 0


if __name__ == "__main__":
    sys.exit(main())
