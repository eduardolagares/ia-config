---
name: agendar-revisao-tarefa
description: >-
  Agenda revisão de tarefa Baladapp (só ST-0): cria registro local em
  ~/.cursor/revisao-tarefas/, sem GitLab nem ST-1+. Use com "revisar tarefa X",
  agendar revisão, ou antes de /executar-revisao-tarefa.
disable-model-invocation: true
---

# agendar-revisao-tarefa

Gatilho: `revisar tarefa <task_ref>` ou `/agendar-revisao-tarefa <task_ref>`.

## Contrato (igual Hermes ST-0 isolado)

Ao executar:

- criar **apenas** ST-0 (registro local = “card pai”)
- **não** consultar GitLab
- **não** chamar APIs GitLab
- **não** rodar ST-1+
- encerrar após ST-0

Monday:

- **permitido só aqui** (ST-0): ler tarefa para montar contexto
- Se `MONDAY_API_TOKEN` existir → API (ver [reference.md](reference.md))
- Se **não** existir → pedir **uma** mensagem com: URL da tarefa, nome, branch principal, lista de projetos (nomes GitLab), executor (nome/id Monday)

Idempotência (`~/.cursor/revisao-tarefas/<task_ref_sanitizado>.json`):

- `status` ∈ `st0_done` … `st6_done` e ≠ `END` → **não** criar; responder com path do registro
- senão → criar ST-0

Resposta:

- sucesso → `Revisão agendada. ST-0:<card_pai_id>`
- erro → `Não consegui agendar <task_ref>. Nenhum processamento iniciado. Motivo:<erro>`

`card_pai_id` = nome do ficheiro JSON (sem extensão).

## ST-0 — Iniciar revisão

### input

- `task_ref` = ID Monday, URL, ou rótulo único acordado com o utilizador

### exec

1. `task_ref_sanitizado` = só `[a-zA-Z0-9._-]`, máx. 120 chars
2. Diretório: `mkdir -p ~/.cursor/revisao-tarefas`
3. Obter dados da tarefa (Monday API **ou** bloco colado pelo utilizador)
4. `branch` = coluna/campo **Branch principal**
5. `projetos_alterados` = scan updates/comentários tarefa principal + subtarefas (nomes de repo GitLab, ex. `ingressos`, `assinaturas`)
6. `executor` = owner subtarefa **Executar** (`id`, `name`)
7. Escrever JSON (ver schema abaixo)
8. Comentário simulado no registro: `Revisão agendada. Card pai: <card_pai_id>. (Cursor)`

### validate

- `branch` não vazio
- `projetos_alterados.length >= 1`
- `executor.id` não vazio
- ficheiro gravado

### output (mostrar no chat)

```
SAÍDA ST-0
```

```json
{
  "branch": "",
  "projetos_alterados": [],
  "task_name": "",
  "task_url": "",
  "executor": { "id": "", "name": "" },
  "card_pai_id": ""
}
```

### next

Parar. Próximo passo humano: `/executar-revisao-tarefa <card_pai_id>`.

## Schema do registro (`~/.cursor/revisao-tarefas/<card_pai_id>.json`)

```json
{
  "status": "st0_done",
  "board": "revisao-de-tarefas-local",
  "card_pai_id": "",
  "task_ref": "",
  "task_name": "",
  "task_url": "",
  "branch": "",
  "projetos_alterados": [],
  "executor": { "id": "", "name": "" },
  "st0_at": "ISO-8601",
  "st1": null,
  "st2": null,
  "st3": null,
  "st4": null,
  "st5": null,
  "st6": null
}
```

## Proibido nesta skill

- `git` em repos de produto (exceto criar pasta de estado)
- GitLab API
- Invocar `executar-revisao-tarefa` ou `/bld-code-review`
- Inferir projetos sem evidência em Monday/entrada do utilizador

## Recursos

- Monday API opcional: [reference.md](reference.md)
- Raiz dos clones: `~/projetos/baladapp/` (default Baladapp)
