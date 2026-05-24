---
name: executar-revisao-tarefa
description: >-
  Executa ST-1 a ST-6 de revisão Baladapp a partir do registro em
  ~/.cursor/revisao-tarefas/ (Git local, GitLab API opcional, code-review).
  Use após agendar-revisao-tarefa, /executar-revisao-tarefa, ou com card_pai_id existente.
disable-model-invocation: true
VERSION: "1.0.1"
---

# executar-revisao-tarefa

Gatilho: `/executar-revisao-tarefa <card_pai_id>`, `executar-revisao-tarefa <card_pai_id>`, ou `executar revisão <card_pai_id>`.

Pré-requisito: ficheiro `~/.cursor/revisao-tarefas/<card_pai_id>.json` com ST-0 válido (`status: st0_done`).

## Regra da cadeia

Cada ST:

1. Ler input do JSON (`st0` … estágio anterior)
2. Executar `exec`
3. `validate`
4. Comentar no chat: `SAÍDA ST-N` + payload
5. Gravar `stN` no JSON e avançar `status`
6. `next` conforme tabela abaixo

Parar em erro de `validate` com mensagem clara; **não** avançar estágio.

Raiz GitLab local default: `~/projetos/baladapp/<project_name>/`.

Host API: `https://gitlab.baladapp.com.br/api/v4` com `PRIVATE-TOKEN: $GITLAB_TOKEN` (opcional; sem token, ST-1/ST-4 ficam parciais — ver notas).

---

## ST-1 — Resolução GitLab

**input:** bloco ST-0 do JSON.

**exec** (para cada `projetos_alterados`):

1. Repo local: `~/projetos/baladapp/<nome>/` (`.git` obrigatório)
2. `git fetch origin` (se rede ok)
3. Confirmar branch ST-0.branch existe: `git rev-parse --verify origin/<branch>` ou local
4. Com `GITLAB_TOKEN`: buscar MR `source_branch=<branch>` `target_branch=master`
5. Se ausente e token ok: criar MR título `Revisão: <task_name> - <branch>`, descrição `task_url`
6. Sem token: `mr_url` vazio, `branch_error` se branch não existir localmente

**validate:** cada item tem `project_id` (id GitLab ou path) e (`mr_url` ou `branch_error` não vazio)

**output:** array JSON (schema Hermes ST-1).

**next:** ST-2

---

## ST-2 — Obter diff

**input:** `branch` ST-0, array ST-1.

**exec** (só `branch_confirmed: true`):

1. `git diff origin/master...origin/<branch>` (ou `master...<branch>`)
2. Montar lista `diffs[]` com paths e hunks
3. Se vazio/falha → `limitacao` descritiva

**validate:** cada projeto tem `diffs[].diff` ou `limitacao`

**output:** array JSON ST-2.

**next:** ST-3

---

## ST-3 — Code review

**input:** ST-2.

**exec:**

1. Montar pacote diff (agrupar por projeto; não colar diff integral no chat final)
2. Aplicar **integralmente** o protocolo da skill `code-review` (títulos exatos dos 4 blocos, pt-BR, read-only)
3. Não chamar GitLab; não executar testes

**validate:** 4 secções; crítico/grave com contexto; vazio = `Nenhum.`

**output:** texto ST-3 (formato Hermes).

**next:** ST-4

---

## ST-4 — Checklist MR

**input:** ST-1, ST-2, ST-3.

**exec** (por MR com `mr_url`):

- Com `GITLAB_TOKEN`: ler discussões/checklist do MR; marcar itens resolvidos no diff; respeitar `#ignorar-revisão` / `#ignorar-revisao` / `[ignorar-revisão]`
- Sem token: **não** atualizar GitLab; produzir checklist **proposto** em markdown no JSON (`thread_url: "manual"`) e contar pendentes a partir de ST-3

**validate:** estrutura JSON ST-4 preenchida

**next:** ST-5

---

## ST-5 — Veredito

**input:** ST-3, ST-4.

**exec:**

- `CORRIGIR` se ST-3 tem itens em **1 - Crítico** ou **2 - Grave** (≠ `Nenhum.`) **ou** `itens_pendentes > 0` em algum MR
- senão `CONTINUAR`

**output:**

```text
Decisão:<CORRIGIR|CONTINUAR>
- ST-3:<resumo crit/grave>
- ST-4:<soma pendentes>
```

**next:** ST-6

---

## ST-6 — Atualizar Monday

**input:** ST-0, ST-1, ST-5.

**exec:**

- Com `MONDAY_API_TOKEN`: aplicar regras Hermes (Revisão de código, status principal/subtarefa Testar, comentário conforme decisão)
- Sem token: emitir **roteiro manual** copiável (status + texto do comentário + executor) para o utilizador colar no Monday

**validate:** `decisao` definida; plano de update documentado ou API ok

**output:** JSON ST-6.

**next:** `END` — gravar `status: END` no JSON.

---

## Resposta final

```
Revisão concluída. <card_pai_id> Decisão:<CORRIGIR|CONTINUAR>
```

Se parou antes de ST-6: `Revisão interrompida em ST-N. Motivo:...`

## Skills relacionadas

- ST-0: `agendar-revisao-tarefa`
- ST-3: `code-review`

## Variáveis de ambiente

| Variável | ST |
|----------|-----|
| `MONDAY_API_TOKEN` | 0 (agendar), 6 |
| `GITLAB_TOKEN` | 1, 4 |
