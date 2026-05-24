---
description: >-
  Pipeline ST-1→ST-6 após agendar. Git + GitLab API opcional + /bld-code-review.
  Uso: /executar-revisao-tarefa <card_pai_id>
---

# `/executar-revisao-tarefa`

Carregar e seguir a skill **executar-revisao-tarefa** (`skills/executar-revisao-tarefa/SKILL.md`).

Argumento obrigatório: `card_pai_id` (nome do ficheiro em `~/.cursor/revisao-tarefas/`).

Pré-requisito: ST-0 já gravado (`/agendar-revisao-tarefa`).

Ordem fixa: ST-1 → ST-2 → ST-3 (protocolo `/bld-code-review`) → ST-4 → ST-5 → ST-6 → `END`.

Parar no primeiro `validate` falhado; não saltar estágios.
