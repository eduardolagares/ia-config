#!/usr/bin/env python3
"""Karpathy SKILL.md upstream → rules/eduardolagares/karpathy-guidelines.mdc."""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path


def read_ia_config_version(repo_root: Path) -> str:
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
    first_nl = text.find("\n", 0)
    if first_nl == -1 or text[:first_nl].strip() != "---":
        return None, text
    rest = text[first_nl + 1 :]
    end = rest.find("\n---")
    if end == -1:
        return None, text
    fm = rest[:end]
    after = rest[end:]
    close_len = after.find("\n", 1)
    body = "" if close_len == -1 else after[close_len + 1 :]
    return fm, body


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


def karpathy_skill_to_mdc(src: Path, dst: Path) -> None:
    raw = src.read_text(encoding="utf-8")
    meta, body = _parse_simple_frontmatter(raw)
    desc = meta.get(
        "description",
        "Diretrizes comportamentais para reduzir erros comuns em código com LLM.",
    )
    body = body.lstrip("\n")
    repo_root = next((p for p in dst.parents if (p / "VERSION").is_file()), dst.parent.parent.parent)
    ver = os.environ.get("IA_CONFIG_CONTENT_VERSION", "").strip() or read_ia_config_version(repo_root)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(
        f"---\ndescription: {json.dumps(desc)}\nVERSION: {json.dumps(ver)}\nalwaysApply: true\n---\n\n{body}",
        encoding="utf-8",
    )


def main() -> int:
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    p_k = sub.add_parser("karpathy-skill-to-mdc")
    p_k.add_argument("src", type=Path)
    p_k.add_argument("dst", type=Path)
    args = p.parse_args()
    if args.cmd == "karpathy-skill-to-mdc":
        karpathy_skill_to_mdc(args.src, args.dst)
    return 0


if __name__ == "__main__":
    sys.exit(main())
