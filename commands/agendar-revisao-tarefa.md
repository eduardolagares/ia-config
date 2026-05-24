---
description: >-
  Agenda revisão (ST-0): registro em ~/.cursor/revisao-tarefas/. Sem GitLab.
  Uso: /agendar-revisao-tarefa <task_ref>
---

# `/agendar-revisao-tarefa`

Carregar e seguir a skill **agendar-revisao-tarefa** (`skills/agendar-revisao-tarefa/SKILL.md`).

Argumento obrigatório: `task_ref` (ID Monday, URL ou identificador).

Contrato de resposta:

- sucesso → `Revisão agendada. ST-0:<card_pai_id>`
- erro → `Não consegui agendar <task_ref>. Nenhum processamento iniciado. Motivo:<erro>`

Não executar ST-1+. Não abrir GitLab.
