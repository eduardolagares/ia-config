---
VERSION: "1.0.3"
description: "Protocolo agente: TDD RED/GREEN; modos Por RF / Por fase; spec↔bld-tdd-doc; modo obrigatório por ativação; retomada→1ª msg só modo; menu 1–7 nos marcos; commit só 1|5; skills tdd-red-guard, tdd-test-naming, tdd-minitest-red; sem tester-rails."
---

# `/bld-tdd-dev` — protocolo (agente)

## Preconditions

- `IF` exists `~/.agents/skills/caveman/SKILL.md` `THEN` load; apply caveman intensity `full`; keep until skill exceptions; `ELSE` skip.
- `THEN` execute remainder in order.

## Spec binding

- Active spec: `docs/specs/tdd/NNNN-AAAA-MM-DD-slug.md` or user path. Filename pattern from `/bld-tdd-doc`.
- `bld-tdd-doc` (`~/.cursor/commands/bld-tdd-doc.md`) authors spec; this command implements + updates status **in that same file**.

## Spec sync (non-negotiable)

- `MUST` persist to active spec any session change affecting understanding: decisions, added/reframed requirements, rules/acceptance criteria, discoveries elevated to requirement, equivalents.
- `FORBIDDEN`: exclusive chat-only record for above; spec markdown = traceable contract.
- Spec edits `MUST` follow `bld-tdd-doc` rules: section order (decisions → phases → flowchart → `## Registros` **only** if **PC1+**); **RF1**, **RF2**, … aligned to phase TDD table; `## Decisões tomadas` with **D1**, **D2**, …; prefer **append** new RF/D/PC + new table rows vs rewriting history unless explicit fix or unsustainable contradiction; **Pós-implementação** phase for implementation-cycle findings; `## Registros pós-conclusão do spec` (**PC1**, **PC2**, …) **only** for maintenance after spec `concluído`; phase headers: checklist + RED/GREEN markers coherent with `concluídos/total`; before save: re-check `bld-tdd-doc` checklist on touched regions.
- Routing: process/product decision → **D**; new testable behavior → **RF** + TDD table row + RED/GREEN alignment; QA/manual finding same delivery cycle → **Pós-implementação**; after spec **concluído**, maintenance/bug outside original cycle → **PC** (create `## Registros` + **PC1** if missing).
- Spec **text-only** changes may be emitted in chat; all other command rules (incl. menu 1–7, commit gates) still apply.

## §1 Mode gate (every activation)

- After caveman block when applicable: output **numbered** mode question **before** any other step. **Every** activation: cold start or resume.
- Accept user reply **only** as explicit number or explicit matching label. **Never** infer mode from history/thread.
- **Explicit resume** triggers (non-exhaustive PT/EN): resume, resumir, reabrir, retomar, continue `/bld-tdd-dev`, seguir de onde parou, equivalents meaning “continue process after pause/new conversation”.
- **On first agent message after explicit resume:** output **only** numbered mode question. **Same message `FORBIDDEN`:** menu 1–7, menu choice prompt, milestone advance, commit suggestion. After mode answered: resume from correct spec point; menu 1–7 auto **only** at §3–§4 milestones (full reprint **only** on explicit menu request per §4); **never** stack menu with mode question on resume.
- **Not** explicit resume: first `/bld-tdd-dev` in thread **or** continuation with mode already answered this session → normal flow; “mode-only first message” binds **first** turn after explicit resume, not each micro-step.

| Dimension | Por RF | Por fase |
|-----------|--------|----------|
| Unit | one table row / iteration | all rows of phase batch |
| Menu 1–7 | after each Confirm RED, each Confirm GREEN, phase end | after RED package closes milestone **(1)**; after GREEN package closes **(2)** |
| Intra-phase pause | — | zero inside write waves; zero between lines in Confirm waves; execute **Por fase** sequence with **no** authorization stops between lines |

## §2 Four-step cycle (per row; total order; no skip/invert)

1. **Escrever RED**
   - `FORBIDDEN` mutating project implementation: production code, `app/`, `lib/`, jobs, migrations, user-facing views/routes/handlers, app runtime config, etc.
   - `ALLOWED` minimal edits so target test **exists + runs**: test file, test-only factories/fixtures/helpers, test `require`/`import` if project requires.
   - `FORBIDDEN` during RED: refactor outside test, pre-implement GREEN, touch any file not strictly required.
   - Before **and** after each write: apply `~/.cursor/commands/skills/tdd-red-guard.md`.
   - On any test identifier: apply `~/.cursor/commands/skills/tdd-test-naming.md`.
   - Minitest projects: also apply `~/.cursor/commands/skills/tdd-minitest-red.md`.

2. **Confirmar RED** — run **only** target test; paste output proving **failure**; lead agent reviews RF adherence inline.

3. **Escrever GREEN** — minimal production to satisfy RED; no premature abstraction, no refactor, no extra code beyond target test.
   - If writing/renaming tests during GREEN: reapply `~/.cursor/commands/skills/tdd-test-naming.md`.

4. **Confirmar GREEN** — run **same** target test only; paste output proving **pass**; lead agent reviews inline; update spec: status, test path, `n/m`.

## §3 Mode flows

### Por RF

`Escrever RED → Confirmar RED → menu 1–7 → Escrever GREEN → Confirmar GREEN → menu 1–7 → próxima linha`

- Phase end: mandatory same-session **senior code review** of phase package; **do not** cite named skills/files for this step → then menu 1–7.

### Por fase

**RED package** (whole package: same RED write rules as §2 — **zero** production; only minimal test-enabling edits):

1. **Onda Escrever RED** — all lines; **no** questions between lines inside wave. Per write: `tdd-red-guard.md`; per identifiers: `tdd-test-naming.md`.
2. **Onda Confirmar RED** — sequential; **no** questions between lines; each line: run **only** target test; paste **failure**; lead agent RF adherence inline.
3. **Revisão sênior** — lead agent senior review of RED package (tests + adherence from confirmations); scope = RED; mandatory; **no** named skill/file. `IF` verdict **REPROVADO** `THEN` block milestone **(1)** until blockers fixed.
4. Menu 1–7 = milestone **(1)**.

**GREEN package** (`ONLY` after RED package valid + **(1)** authorized):

1. **Onda Escrever GREEN** — all lines; **no** questions between lines.
2. **Onda Confirmar GREEN** — sequential; **no** questions between lines; each line: run **only** target test; paste **pass**; lead agent inline review; update spec per line (`n/m`, status, path).
3. **Revisão sênior** — lead agent senior review GREEN package; scope = GREEN; mandatory; **no** named skill/file. `IF` **REPROVADO** `THEN` block **(2)** until fixed.
4. Menu 1–7 = milestone **(2)**.

## §4 Menu 1–7 (sole commit / milestone-advance channel)

- Show **only** at iteration-end milestones per §3. **Explicit resume (§1):** **do not** show this menu in same message as mode question; show **only** after mode chosen **and** flow reaches milestone.
- **Explicit menu request** (dedicated or clearly primary message; PT/EN patterns include: menu, menu 1-7, menu 1–7, menu iteração, mostrar menu, opções do menu, obvious equivalents): print **full** numbered menu 1–7 below; **does not** substitute numeric **1–7** choice for advance/commit; await explicit number/label. **Exception:** first message after explicit resume → mode-only; after mode set, `menu` at valid milestone prints full 1–7.
- `git commit` `FORBIDDEN` until user picks **1** or **5** from this menu after menu shown. **Forbidden:** infer “yes”, end-of-message commit, convenience commit. No **1|5** → **zero** commits.

| # | Action |
|---|--------|
| 1 | **Comitar e continuar** — `IF` user chose **1** `THEN` `git add` full round artifacts + `git commit` descriptive; show command output; advance next milestone. `IF` clean working tree `THEN` report + advance without commit. |
| 2 | **Revisar manualmente** — stop; await input; no commit. On return: `IF` explicit resume `THEN` first reply mode-only (§1); `ELSE` at menu milestone re-show 1–7. |
| 3 | **Revisão sênior extra** — second same-session senior review; scope per user; no named skill/file; show findings; no auto-commit; re-show 1–7. |
| 4 | **Discutir requisito** — adjust spec; ask implement-before-code; no commit; when choosing version/advance/reviewer suggestions map to numeric menu (e.g. 1, 5, 6, 7). |
| 5 | **Só comitar** — `IF` user chose **5** `THEN` descriptive `git commit` only; **do not** advance milestone. Next return: explicit resume → mode-only first (§1); else re-show 1–7 at milestone. |
| 6 | **Continuar sem comitar** — advance next milestone immediately; no commit. |
| 7 | **Aceitar sugestões do revisor sênior** — apply code/spec per **latest** senior review this session (incl. extra if newest); no auto-commit; end → re-show 1–7 at milestone (explicit resume: §1 non-stack with mode). |

- `FORBIDDEN`: `tester-rails`.

## §5 Hard constraints

- Commit: `git commit` **only** path = menu 1–7 shown + user **1** or **5**.
- RED: no project implementation files touched; no line beyond strict test necessity; no collateral refactor; no GREEN prep. Uncertain file scope → read `tdd-red-guard.md` **before** write; if still uncertain → **do not** change.
- Tests: **never** full suite; **only** target test per step.
- New requirement: spec first; user confirm before implement.
- Test names: PT; observable behavior; no abbreviations; RF reference mandatory; full rules in `tdd-test-naming.md`.
- Progress: mirror `n/m` in spec table **and** chat.
