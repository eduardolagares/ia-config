---
VERSION: "1.2.0"
description: "Agent protocol EN; deliverable spec PT; TDD RED/GREEN; Per RF / Per phase; spec↔bld-tdd-doc; mandatory mode each activation; resume→first message mode-only; menu 1–7 at milestones; commit only 1|5; RED/GREEN parallelism in Per phase under spec hierarchy; post–RED package sets RED column in spec; skills tdd-red-guard, tdd-test-naming, tdd-minitest-red; no tester-rails."
---

# `/bld-tdd-dev` — protocol (agent)

## Language split (mandatory)

- **This command / agent behavior:** instructions, reasoning, procedures, and milestone prompts **in English** unless the user explicitly asks otherwise for chat.
- **Deliverable spec** (`docs/specs/tdd/…` active file): **Portuguese (`PT`)** for all substantive prose the template allows you to author — RF bullets, **D**/**PC** lines, phase narrative/checklists, register notes, and any free-text cells — **without** translating stable template headings (`## Decisões tomadas`, `## Fase`, etc.) or breaking **bld-tdd-doc** structure. Do **not** switch the spec body to English unless the user **explicitly** requests it.
- **Tests:** names and observable behavior wording **PT** per `tdd-test-naming.md`; code/comments follow project norms.

## Preconditions

- `IF` exists `~/.agents/skills/caveman/SKILL.md` `THEN` load; apply caveman intensity `full`; keep until skill exceptions; `ELSE` skip.
- `THEN` execute remainder in order.

## Spec binding

- Active spec: `docs/specs/tdd/NNNN-AAAA-MM-DD-slug.md` or user path. Filename pattern from `/bld-tdd-doc`.
- `bld-tdd-doc` (`~/.cursor/commands/bld-tdd-doc.md`) authors spec; this command implements + updates status **in that same file**.

## Spec sync (non-negotiable)

- `MUST` persist to active spec any session change affecting understanding: decisions, added/reframed requirements, rules/acceptance criteria, discoveries elevated to requirement, equivalents — **in Portuguese** per **Language split**.
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

| Dimension | Per RF | Per phase |
|-----------|--------|-----------|
| Unit | one table row / iteration | all rows of phase batch |
| Menu 1–7 | after each Confirm RED, each Confirm GREEN, phase end | after RED package closes milestone **(1)**; after GREEN package closes **(2)** |
| Intra-phase pause | — | zero inside write waves; zero between lines in Confirm waves; execute **Per phase** sequence with **no** authorization stops between lines |

## §2 Four-step cycle (per row; total order; no skip/invert)

In **Per phase**, each **wave** may contain **parallel batches** of rows provided **§3 Parallelism and hierarchy** is respected; do not invert RED vs GREEN steps nor GREEN before Confirm RED on the same row.

1. **Write RED**
   - `FORBIDDEN` mutating project implementation: production code, `app/`, `lib/`, jobs, migrations, user-facing views/routes/handlers, app runtime config, etc.
   - `ALLOWED` minimal edits so target test **exists + runs**: test file, test-only factories/fixtures/helpers, test `require`/`import` if project requires.
   - `FORBIDDEN` during RED: refactor outside test, pre-implement GREEN, touch any file not strictly required.
   - Before **and** after each write: apply `~/.cursor/commands/skills/tdd-red-guard.md`.
   - On any test identifier: apply `~/.cursor/commands/skills/tdd-test-naming.md`.
   - Minitest projects: also apply `~/.cursor/commands/skills/tdd-minitest-red.md`.

2. **Confirm RED** — run **only** target test; paste output proving **failure**; lead agent reviews RF adherence inline.

3. **Write GREEN** — minimal production to satisfy RED; no premature abstraction, no refactor, no extra code beyond target test.
   - If writing/renaming tests during GREEN: reapply `~/.cursor/commands/skills/tdd-test-naming.md`.

4. **Confirm GREEN** — run **same** target test only; paste output proving **pass**; lead agent reviews inline; update spec: status, test path, `n/m`.

## §3 Mode flows

### Per RF

`Write RED → Confirm RED → menu 1–7 → Write GREEN → Confirm GREEN → menu 1–7 → next row`

- Phase end: mandatory same-session **senior code review** of phase package; **do not** cite named skills/files for this step → then menu 1–7.

### Per phase

#### Parallelism and hierarchy (RED and GREEN)

- **Hierarchy source:** order of `## Fase` sections; within the phase, TDD table (**`Paralelo`** column: `—`, `c/ #N`, `após #N`) and **`## Fluxograma de fases e RFs`** to resolve ambiguity.
- **Rules:** `MAY` run **multiple rows in parallel** (e.g. concurrent edits and test commands, subagents) **iff** no row in the batch starts before dependencies from the doc for that step are satisfied.
  - **Write RED / Confirm RED wave:** row **R** joins a parallel batch only after **every** predecessor **P** required by the hierarchy has finished **Confirm RED** in this package. E.g. `após #N` ⇒ **N** before **R** (unless cross-phase flowchart says otherwise). `c/ #N` ⇒ coordinate with **N** after shared predecessors are satisfied. `—` ⇒ ascending chain by `#` per **bld-tdd-doc** unless the flowchart contradicts.
  - **Write GREEN / Confirm GREEN wave:** same rule with **Confirm GREEN** as the gating predecessor wherever hierarchy between rows requires order (including when `após #N` in the spec binds RF order).
- **RF text:** if the requirement clearly depends on behavior that exists only after another row’s GREEN, **do not** parallelize beyond what that dependency requires (spec graph + test common sense).

**RED package** (whole package: same RED write rules as §2 — **zero** production; only minimal test-enabling edits):

1. **Write RED wave** — all rows in the package; **no** questions inside wave. **MAY** parallelize rows in **batches** honoring **Parallelism and hierarchy** above (multiple rows at once within a batch; batches sequential if the DAG requires). Per written file: `tdd-red-guard.md`; per identifiers: `tdd-test-naming.md`.
2. **Confirm RED wave** — **no** questions between lines. **MAY** parallelize runs **only** among rows whose **Write RED** is done **and** whose hierarchy does not require waiting on a predecessor’s **Confirm RED** (otherwise confirm predecessors first or serialize). Each row: run **only** target test; paste **failure**; RF adherence review inline.
3. **Spec after phase RED** — `MUST` update the active spec **at this point**: for **each** package row with RED confirmed, TDD table **RED** column = **`✅`** (replace **`🔄`**/**`⬜`** per **bld-tdd-doc**). **`MUST NOT`** set **GREEN** **`✅`** here; phase header (`done`/`total`, icon) follows **bld-tdd-doc** (`done` counts only when **RED** and **GREEN** are **`✅`** on the same row). **Human-readable** edits stay **PT**.
4. **Senior review** — lead agent senior review of RED package (tests + adherence from confirmations + spec **RED** **`✅`** coherent); scope = RED; mandatory; **no** named skill/file. `IF` verdict **REJECTED** `THEN` block milestone **(1)** until blockers fixed.
5. Menu 1–7 = milestone **(1)**.

**GREEN package** (`ONLY` after RED package valid + **(1)** authorized):

1. **Write GREEN wave** — all lines; **no** questions between lines. **MAY** parallelize batches like RED, honoring **Parallelism and hierarchy**.
2. **Confirm GREEN wave** — **no** questions between lines. **MAY** parallelize confirmations among rows eligible per hierarchy. Each row: run **only** target test; paste **pass**; lead agent inline review; update spec per row (`n/m`, status, path, **GREEN** **`✅`** when applicable).
3. **Senior review** — lead agent senior review GREEN package; scope = GREEN; mandatory; **no** named skill/file. `IF` **REJECTED** `THEN` block **(2)** until fixed.
4. Menu 1–7 = milestone **(2)**.

## §4 Menu 1–7 (sole commit / milestone-advance channel)

- Show **only** at iteration-end milestones per §3. **Explicit resume (§1):** **do not** show this menu in same message as mode question; show **only** after mode chosen **and** flow reaches milestone.
- **Explicit menu request** (dedicated or clearly primary message; PT/EN patterns include: menu, menu 1-7, menu 1–7, menu iteração, mostrar menu, opções do menu, obvious equivalents): print **full** numbered menu below using **Portuguese labels** as shown; procedural explanations to the user **in English** are optional if clarity needs it — **spec edits remain PT**.
- `git commit` `FORBIDDEN` until user picks **1** or **5** from this menu after menu shown. **Forbidden:** infer “yes”, end-of-message commit, convenience commit. No **1|5** → **zero** commits.

| # | Ação (rótulo PT para o utilizador) |
|---|--------|
| 1 | **Comitar e continuar** — `IF` user chose **1** `THEN` `git add` full round artifacts + `git commit` descriptive; show command output; advance next milestone. `IF` clean working tree `THEN` report + advance without commit. |
| 2 | **Revisar manualmente** — stop; await input; no commit. On return: `IF` explicit resume `THEN` first reply mode-only (§1); `ELSE` at menu milestone re-show 1–7. |
| 3 | **Revisão sênior extra** — second same-session senior review; scope per user; no named skill/file; show findings; no auto-commit; re-show 1–7. |
| 4 | **Discutir requisito** — adjust spec (**PT**); ask implement-before-code; no commit; when choosing version/advance/reviewer suggestions map to numeric menu (e.g. 1, 5, 6, 7). |
| 5 | **Só comitar** — `IF` user chose **5** `THEN` descriptive `git commit` only; **do not** advance milestone. Next return: explicit resume → mode-only first (§1); else re-show 1–7 at milestone. |
| 6 | **Continuar sem comitar** — advance next milestone immediately; no commit. |
| 7 | **Aceitar sugestões do revisor sênior** — apply code/spec per **latest** senior review this session (incl. extra if newest); spec prose stays **PT**; no auto-commit; end → re-show 1–7 at milestone (explicit resume: §1 non-stack with mode). |

- `FORBIDDEN`: `tester-rails`.

## §5 Hard constraints

- Commit: `git commit` **only** path = menu 1–7 shown + user **1** or **5**.
- RED: no project implementation files touched; no line beyond strict test necessity; no collateral refactor; no GREEN prep. Uncertain file scope → read `tdd-red-guard.md` **before** write; if still uncertain → **do not** change.
- Tests: **never** full suite; **only** target test per step.
- New requirement: spec first; user confirm before implement.
- Test names: Portuguese **Language split** + `tdd-test-naming.md`; observable behavior; no abbreviations; RF reference mandatory.
- Progress: mirror `n/m` in spec table **and** chat.
