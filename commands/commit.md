---
description: "Diff/staging → short pt-BR message → git add + commit; no permission prompts."
---

# `/commit`

**MUST:** `git status -sb`; `git diff`; `git diff --cached` if staged exists. Draft message from real diff only. `git add` (see below) + `git commit`. Reply: subject line, 1–3 sentence delta summary, commit output or abort reason.

**Message (pt-BR):** imperative; subject ≤72 chars; body max 5 lines, blank line before body only if needed. No vague/generic subject; no English in subject; no emoji; no file laundry lists in subject.

**Add scope:** staged + no user paths → commit staged only (non-empty cache). no staged → `git add -A` at repo root then commit. user listed paths → `git add` those only.

**Commit:** `-m` subject; second `-m` if body.

**STOP (no commit):** clean tree; merge/rebase conflict or blocked git state.

**NEVER:** ask to commit; stop after message without commit (unless STOP); `git push` unless same-turn user request. **No tool attribution** in commit subject/body **or** in the post-commit reply: do not name or credit Cursor, Claude, Copilot, ChatGPT, IDE, “IA”, “assistente”, or equivalents.

**Conflict:** another active slash command forbids commits → report; do not commit.
