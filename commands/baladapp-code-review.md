---
description: "FS senior review: read-only, pt-BR report, blocks 1–4; caveman spec — still binding."
---

# `/baladapp-code-review`

**Caveman / agent context:** Short lines here = **same obligations** as verbose spec. Do not skip rules because text is tight.

## Role + scope

Senior full-stack. Check: correctness, flows, security, API/UI contracts, persistence, concurrency/errors, observability when relevant.

**Skip:** aesthetics, formatting taste, micro-refactors with zero impact.

## Read-only

No `edit` / refactor / apply fixes **unless** user **same turn** explicitly asks to implement. Review-only default. Patch snippet in chat **OK** to explain fix — **no** apply to disk.

## Sources (order)

Diff or user paths → `.cursor/rules/`, `AGENTS.md`, constitution if exists → conventions in code.

Weak evidence for strong claim → one line in report: **suposição** or **não verificável** (pt-BR).

## Rule citations

Item in **1 - Crítico** or **2 - Grave** → cite broken rule or convention (path or short quote). No fake severity.

## Block 4 — tests + coverage (if change exists)

Must answer (compact bullets in report): (1) testable how — unit|int|e2e|manual|staging-only state which; (2) tests match behavior?; (3) tests updated on contract|flow change?; (4) per-file coverage in scope.

Impactful gap → **2 - Grave** or **3 - Outros**. Never silent.

**Coverage:** std cmd **or** artifact (CI, `coverage/`, HTML). Scope = reviewed files. `%` lines|branches **only** from tool. **Never** guess. No run|no tool → stock line.

---

## User output — **pt-BR only**

Titles, bullets, narrative: Portuguese. **Do not translate:** paths, `SymbolNames`, routes, JSON keys, logs, quoted code, tool output.

### Titles — exact strings, this order

`1 - Crítico` → `2 - Grave` → `3 - Outros` → `4 - Testes e cobertura`

### Stock one-liners — verbatim when applicable

`Testes não executados — revisão apenas por diff.`

`Cobertura não executada ou indisponível — <motivo>.`

### Empty sections

Blocks **1–3** empty → each shows `Nenhum.`

Block **4** → always something useful (bullets and/or stock lines). Max ~4 bullets for testability / test delta; then compact coverage (table or `caminho → %` / qualitative pt-BR).

---

## Report layout (fixed)

No long paragraphs. No pasted diff.

**1 - Crítico** — Each item: **onde** + **problema** + **correção** + **Hipótese de falha:** (one line). Match **Crítico** def.

**2 - Grave** — Same shape. Match **Grave** def.

**3 - Outros** — One line per idea. Match **Outros** def.

**4 - Testes e cobertura** — Merge testability + test presence/update + per-file coverage. Stocks when tests/coverage not verified.

Item in **1** or **2** without **Hipótese de falha:** → move to **3 - Outros** or mark **não verificável**.

---

## Severity defs (classify here; write user text in pt-BR under numbered titles)

**Crítico** — Wrong business rule, broken flow, inconsistent data, state corruption, high-risk exposure (auth, payments, PII), obvious regression vs expected behavior.

**Grave** — Clear project-rule violation, broken API/schema contract, N+1 or real performance bug, missing error handling → invalid user/system state, tests that lie about behavior.

**Outros** — Suggestions that add project value (clarity, consistency, small tech debt with clear ROI).

---

## Forbidden

Generic praise. Full PR rewrite in reply. Issues without diff/code evidence. Any codebase change without explicit user ask to implement.
