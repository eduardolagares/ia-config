---
name: tdd-dev
description: >-
  Ciclo TDD RED/GREEN (Por RF / Por fase / Completo); spec PT em docs/specs/tdd/;
  pareia com tdd-doc; menu 1–7; commit só opções 1|5. Use com /tdd-dev, "tdd-dev",
  ou para implementar spec TDD existente.
disable-model-invocation: true
VERSION: "1.0.0"
---

# tdd-dev — protocol (agent)

## Language split (mandatory)

- **This skill / agent behavior:** instructions, reasoning, procedures, and milestone prompts **in English** unless the user explicitly asks otherwise for chat.
- **Deliverable spec** (`docs/specs/tdd/…` active file): **Portuguese (`PT`)** for all substantive prose the template allows you to author — RF bullets, **D**/**PC**/**UC** lines, phase narrative/checklists, register notes, and any free-text cells — **without** translating stable template headings (`## Decisões tomadas`, `## Fase`, etc.) or breaking **tdd-doc** structure. Do **not** switch the spec body to English unless the user **explicitly** requests it.
- **Tests:** names and observable behavior wording **PT** per `tdd-test-naming.md`; code/comments follow project norms.

## Preconditions

- `IF` exists `~/.agents/skills/caveman/SKILL.md` `THEN` load; apply caveman intensity `full`; keep until skill exceptions; `ELSE` skip.
- `THEN` execute remainder in order.

## Spec binding

- Active spec: `docs/specs/tdd/NNNN-AAAA-MM-DD-slug.md` or user path. Filename pattern from `tdd-doc`.
- `tdd-doc` authors spec; this skill implements + updates status **in that same file**.

## Spec sync (non-negotiable)

- `MUST` persist to active spec any session change affecting understanding: decisions, added/reframed requirements, rules/acceptance criteria, discoveries elevated to requirement, equivalents — **in Portuguese** per **Language split**.
- `FORBIDDEN`: exclusive chat-only record for above; spec markdown = traceable contract.
- Spec edits `MUST` follow `tdd-doc` rules: section order (decisions → `## Casos de uso` (**UC1+** catalog) → phases → `## Fluxograma de casos de uso` → `## Registros` **only** if **PC1+**); **RF1**, **RF2**, … aligned to phase TDD table; `## Decisões tomadas` with **D1**, **D2**, …; prefer **append** new RF/D/PC/UC + new table rows vs rewriting history unless explicit fix or unsustainable contradiction; **Pós-implementação** phase for implementation-cycle findings; `## Registros pós-conclusão do spec` (**PC1**, **PC2**, …) **only** for maintenance after spec `concluído`; phase headers: checklist + RED/GREEN markers coherent with `concluídos/total`; before save: re-check `tdd-doc` checklist on touched regions.
- Routing: process/product decision → **D**; new testable behavior → **RF** + TDD table row + RED/GREEN alignment; QA/manual finding same delivery cycle → **Pós-implementação**; after spec **concluído**, maintenance/bug outside original cycle → **PC** (create `## Registros` + **PC1** if missing).
- Spec **text-only** changes may be emitted in chat; all other skill rules (incl. menu 1–7, commit gates) still apply.

## §1 Mode gate (every activation)

- After caveman block when applicable: output **numbered** mode question **before** any other step. **Every** activation: cold start or resume.
- **Mode options** (PT labels for user; agent prose in English):

  | # | Modo |
  |---|------|
  | 1 | **Por RF** — one table row per iteration; menu 1–7 after each Confirm RED and each Confirm GREEN. |
  | 2 | **Por fase** — RED then GREEN package per phase; menu 1–7 at milestones **(1)** and **(2)** only. |
  | 3 | **Completo** — all phases end-to-end; **zero** pauses until every RED and every GREEN of every phase is done; menu 1–7 **once** at the end. |

- Accept user reply **only** as explicit number or explicit matching label (`Por RF` / `Per RF`, `Por fase` / `Per phase`, `Completo`). **Never** infer mode from history/thread.
- **Explicit resume** triggers (non-exhaustive PT/EN): resume, resumir, reabrir, retomar, continue `tdd-dev`, seguir de onde parou, equivalents meaning "continue process after pause/new conversation".
- **On first agent message after explicit resume:** output **only** numbered mode question. **Same message `FORBIDDEN`:** menu 1–7, menu choice prompt, milestone advance, commit suggestion. After mode answered: resume from correct spec point; menu 1–7 auto **only** at §3–§4 milestones (**Completo:** sole end-of-run milestone per §3); full reprint **only** on explicit menu request per §4; **never** stack menu with mode question on resume.
- **Not** explicit resume: first `tdd-dev` in thread **or** continuation with mode already answered this session → normal flow; "mode-only first message" binds **first** turn after explicit resume, not each micro-step.

| Dimension | Per RF | Per phase | Completo |
|-----------|--------|-----------|----------|
| Unit | one table row / iteration | all rows of one phase | all rows of **all** phases |
| Menu 1–7 | after each Confirm RED, each Confirm GREEN, phase end | after RED package **(1)**; after GREEN package **(2)** | **once** after last phase GREEN package + final senior review |
| Pause / authorization | every row boundary | zero inside phase waves; stops at **(1)** and **(2)** | **zero** until full run complete; phase progress report only |
| Intra-phase execution | — | zero inside write waves; zero between Confirm lines | same as **Per phase**; chain phases with **no** stop between them |

## §2 Four-step cycle (per row; total order; no skip/invert)

In **Per phase** and **Completo**, each **wave** may contain **parallel batches** of rows provided **§3 Parallelism and hierarchy** is respected; do not invert RED vs GREEN steps nor GREEN before Confirm RED on the same row.

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

- **Hierarchy source:** order of `## Fase` sections; within the phase, TDD table (**`Paralelo`** column: `—`, `c/ #N`, `após #N`); cross-phase only when the spec's **`Paralelo`** / table row references explicitly tie a row to another phase's `#`.
- **Rules:** `MAY` run **multiple rows in parallel** (e.g. concurrent edits and test commands, subagents) **iff** no row in the batch starts before dependencies from the doc for that step are satisfied.
  - **Write RED / Confirm RED wave:** row **R** joins a parallel batch only after **every** predecessor **P** required by the hierarchy has finished **Confirm RED** in this package. E.g. `após #N` ⇒ **N** before **R** (including cross-phase when **`Paralelo`** references a row in another phase). `c/ #N` ⇒ coordinate with **N** after shared predecessors are satisfied. `—` ⇒ ascending chain by `#` per **tdd-doc** within the phase unless **`Paralelo`** states otherwise.
  - **Write GREEN / Confirm GREEN wave:** same rule with **Confirm GREEN** as the gating predecessor wherever hierarchy between rows requires order (including when `após #N` in the spec binds RF order).
- **RF text:** if the requirement clearly depends on behavior that exists only after another row's GREEN, **do not** parallelize beyond what that dependency requires (`Paralelo`/phase order + test common sense).

**RED package** (whole package: same RED write rules as §2 — **zero** production; only minimal test-enabling edits):

1. **Write RED wave** — all rows in the package; **no** questions inside wave. **MAY** parallelize rows in **batches** honoring **Parallelism and hierarchy** above (multiple rows at once within a batch; batches sequential if the DAG requires). Per written file: `tdd-red-guard.md`; per identifiers: `tdd-test-naming.md`.
2. **Confirm RED wave** — **no** questions between lines. **MAY** parallelize runs **only** among rows whose **Write RED** is done **and** whose hierarchy does not require waiting on a predecessor's **Confirm RED** (otherwise confirm predecessors first or serialize). Each row: run **only** target test; paste **failure**; RF adherence review inline.
3. **Spec after phase RED** — `MUST` update the active spec **at this point**: for **each** package row with RED confirmed, TDD table **RED** column = **`✅`** (replace **`🔄`**/**`⬜`** per **tdd-doc**). **`MUST NOT`** set **GREEN** **`✅`** here; phase header (`done`/`total`, icon) follows **tdd-doc** (`done` counts only when **RED** and **GREEN** are **`✅`** on the same row). **Human-readable** edits stay **PT**.
4. **Senior review** — lead agent senior review of RED package (tests + adherence from confirmations + spec **RED** **`✅`** coherent); scope = RED; mandatory; **no** named skill/file. `IF` verdict **REJECTED** `THEN` block milestone **(1)** until blockers fixed.
5. Menu 1–7 = milestone **(1)**.

**GREEN package** (`ONLY` after RED package valid + **(1)** authorized):

1. **Write GREEN wave** — all lines; **no** questions between lines. **MAY** parallelize batches like RED, honoring **Parallelism and hierarchy**.
2. **Confirm GREEN wave** — **no** questions between lines. **MAY** parallelize confirmations among rows eligible per hierarchy. Each row: run **only** target test; paste **pass**; lead agent inline review; update spec per row (`n/m`, status, path, **GREEN** **`✅`** when applicable).
3. **Senior review** — lead agent senior review GREEN package; scope = GREEN; mandatory; **no** named skill/file. `IF` **REJECTED** `THEN` block **(2)** until fixed.
4. Menu 1–7 = milestone **(2)**.

### Completo

- **Scope:** every `## Fase` section in spec order, from first phase with pending rows through last phase. On resume: start at first phase/row not fully **RED ✅ + GREEN ✅**; do **not** re-run completed rows unless spec contradicts.
- **Per phase** (sequential phases; **Per phase** package rules inside each): apply **Parallelism and hierarchy** above; **RED package** steps 1–4 (Write RED wave → Confirm RED wave → spec RED **`✅`** → senior review RED); **GREEN package** steps 1–3 (Write GREEN wave → Confirm GREEN wave → senior review GREEN). **`FORBIDDEN`** menu 1–7, user prompts, authorization stops, or "wait for input" **between** phases or **inside** a phase.
- **Senior review REJECTED** (RED or GREEN, any phase): fix blockers inline in same run; re-run affected confirmations; **do not** stop for menu or user unless fix is impossible without new requirement → then halt with spec-first **D**/ **RF** per §5 and report blocker (only allowed stop mid-run).
- **Phase complete report** (`MUST` after each phase's GREEN package passes senior review, **before** next phase): brief chat summary in English — phase name/header, `concluídos/total` from spec, count of rows with RED **`✅`** and GREEN **`✅`**, next phase name or "last phase done". **No** menu; immediately continue.
- **Run end** (all phases, all rows RED **`✅`** + GREEN **`✅`**): mandatory final senior review of full implementation cycle (all phases); **then** menu 1–7 **once** (milestone equivalent to **(2)** on last phase).

## §4 Menu 1–7 (sole commit / milestone-advance channel)

- Show **only** at iteration-end milestones per §3 (**Completo:** single show at run end per §3). **Explicit resume (§1):** **do not** show this menu in same message as mode question; show **only** after mode chosen **and** flow reaches milestone.
- **Explicit menu request** (dedicated or clearly primary message; PT/EN patterns include: menu, menu 1-7, menu 1–7, menu iteração, mostrar menu, opções do menu, obvious equivalents): print **full** numbered menu below using **Portuguese labels** as shown; procedural explanations to the user **in English** are optional if clarity needs it — **spec edits remain PT**.
- `git commit` `FORBIDDEN` until user picks **1** or **5** from this menu after menu shown. **Forbidden:** infer "yes", end-of-message commit, convenience commit. No **1|5** → **zero** commits.

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

- Commit: `git commit` **only** path = menu 1–7 shown + user **1** or **5** (**Completo:** menu appears only after full run).
- **Completo:** **FORBIDDEN** menu 1–7, commit suggestion, or user authorization between phases; **FORBIDDEN** stopping after one phase unless run complete or §3 blocker halt.
- RED: no project implementation files touched; no line beyond strict test necessity; no collateral refactor; no GREEN prep. Uncertain file scope → read `tdd-red-guard.md` **before** write; if still uncertain → **do not** change.
- Tests: **never** full suite; **only** target test per step.
- New requirement: spec first; user confirm before implement.
- Test names: Portuguese **Language split** + `tdd-test-naming.md`; observable behavior; no abbreviations; RF reference mandatory.
- Progress: mirror `n/m` in spec table **and** chat.
