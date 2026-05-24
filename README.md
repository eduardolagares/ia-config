---
VERSION: "0.0.12"
description: "README do baladapp-ia-config — visão geral, instalação, atualização e skills opcionais."
---

# baladapp-ia-config

**Idioma deste README:** português do Brasil (pt-BR).

Repositório de **regras**, **skills** e scripts de instalação para alinhar o assistente de IA ao **seu** fluxo (Ruby on Rails, TDD, convenções de **equipe**). O fluxo documentado é **um** `curl` para `install.sh` ou `upgrade.sh`: o script clona este repo, **baixa** o Karpathy a partir do [SKILL.md original](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md) (via **curl** + **python3** no clone) e aplica a configuração no **Cursor** e/ou **`~/.agents`**. **Requisitos:** **git**, **curl** e **python3**. O pacote de skills **Caveman** é **opcional** e **não** é instalado por estes scripts; veja [Skills Caveman (recomendado)](#skills-caveman-recomendado). Para **atualizar** o `main`, use [Atualizar](#atualizar).

## Instalação

A instalação é **sempre** este comando (**baixa** `install/install.sh` da branch `main` e executa):

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash
```

O script **clona** [eduardolagares/ia-config](https://github.com/eduardolagares/ia-config) em **`main`** para uma pasta temporária e pergunta:

1. **Destino** — `~/.cursor` ou `~/.agents` (global ou por projeto)
2. **Extras** — no modo Cursor, pode marcar sync adicional para `.agents`

Suportados pelo instalador: **Cursor** e **`.agents`** apenas.

Tudo vive em **`rules/eduardolagares/`** e **`skills/eduardolagares/`** no repo e nos destinos instalados.

Simular sem alterar **arquivos**:

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash -s -- --dry-run
```

---

## Atualizar

Para alinhar com o último **`main`** sem reinstalar tudo **manualmente**, use **`upgrade.sh`**: mesmo tipo de `curl` que na [Instalação](#instalação), mas o script é `upgrade.sh` (clone em pasta temporária e sincronização com o repo).

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/upgrade.sh | bash
```

Simular:

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/upgrade.sh | bash -s -- --dry-run
```

Alternativa: rodar de novo o `curl` de [Instalação](#instalação) se você quiser repetir o fluxo completo de primeira instalação.

No **upgrade**, o instalador re-sincroniza `rules/eduardolagares/` e `skills/eduardolagares/` (remove artefactos legados de layouts antigos).

Scripts: `install/install.sh`, `install/upgrade.sh`, `install/cursor.sh`, `install/agents.sh`, `install/lib/`.

### Destinos após instalação

| Escolha | Rules | Skills |
|---------|-------|--------|
| Cursor global | `~/.cursor/rules/eduardolagares/` | `~/.cursor/skills/eduardolagares/` |
| Cursor projeto | `<proj>/.cursor/rules/eduardolagares/` | `<proj>/.cursor/skills/eduardolagares/` |
| `.agents` global | `~/.agents/rules/eduardolagares/` | `~/.agents/skills/eduardolagares/` |
| `.agents` projeto | `<proj>/.agents/rules/eduardolagares/` | `<proj>/.agents/skills/eduardolagares/` |

Karpathy: `rules/eduardolagares/karpathy-guidelines.mdc` (gerado no install, não versionado no Git).

---

## Skills (`skills/eduardolagares/`)

Skills copiadas pelo instalador para `~/.cursor/skills/eduardolagares/` (Cursor) ou destino equivalente na IDE. Cada uma usa `disable-model-invocation: true` — invoque explicitamente pelo nome.

| Skill | O que faz |
|-------|-----------|
| `comitar` | Lê `git diff`/staging, gera mensagem curta em pt-BR e executa `git add` + `git commit` sem pedir confirmação. |
| `tdd-doc` | Monta o spec de requisitos + TDD (RED/GREEN) em markdown, sem implementar código no chat. |
| `tdd-dev` | Ciclo TDD de implementação (RED/GREEN) por RF, fase ou completo; menu de iteração; segue spec de `tdd-doc`. |
| `code-review` | Revisão sénior **read-only** em pt-BR: correção, fluxos, segurança, contratos, persistência, concorrência. |
| `agendar-revisao-tarefa` | ST-0: agenda revisão (registro em `~/.cursor/revisao-tarefas/`); Monday opcional; sem GitLab. |
| `executar-revisao-tarefa` | ST-1→ST-6: Git local, GitLab API opcional, review `code-review`, update Monday manual ou API. |

---

## Regras (`rules/eduardolagares/`)

Regras `.mdc` (Cursor **User Rules** / globs) copiadas para `rules/eduardolagares/` no destino.

| Arquivo | Tema |
|---------|------|
| `clean_code_ruby.mdc` | Clean code Rails — time zones, erros, fronteiras AR; sintaxe/nomes → `ruby.mdc`. |
| `controllers.mdc` | Controllers magros — Pundit, strong params, REST, use cases / queries. |
| `implementation.mdc` | Edits mantêm testes em sincronia — achar spec contraparte, atualizar contratos, rodar testes focados. |
| `migrations.mdc` | Migrations Rails — gerador, prefixo de versão, reversibilidade, índices, FKs, Postgres seguro. |
| `models.mdc` | Models AR magros — validações, scopes, enums; orquestração fora. |
| `query_objects.mdc` | Query objects — read-only, `relation:` / `@relation`, `self.call`, YARD. |
| `rule_objects.mdc` | Rule objects — uma pergunta de domínio, `#result` primitivo, read-only. |
| `ruby.mdc` | Estilo Ruby — kwargs, nomes, fluxo de controle, sem meta desnecessária. |
| `use_cases.mdc` | Use cases — `Dry::Monads::Result`, namespace por domínio, sem `dry-transaction`. |
| `views.mdc` | Views — ViewComponent, presenters, I18n, templates burros. |
| `writting-tests-rails.mdc` | Testes Minitest — TDD, naming, asserções de negócio, isolamento. |
| `writting-tests-react.mdc` | Testes Vitest + Testing Library — layout `js-tests/`, naming, config raiz vs submódulo. |

> A regra `karpathy-guidelines.mdc` **não** está versionada neste repo: o `install/` baixa o [SKILL.md original](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md) e converte para `.mdc` durante a instalação.

---

## Skills Caveman (recomendado)

**Projeto:** <https://github.com/JuliusBrussee/caveman>

O ecossistema **Caveman** (modo compacto, commit/review/compress, cavecrew, …) é um **pacote de skills de terceiros** que **recomendamos**, mas **não** faz parte do `install.sh` nem do `upgrade.sh` deste repositório. **Instale e atualize pelo próprio projeto Caveman** (instruções e releases no repositório oficial).

**Por quê:** a skill `tdd-dev` referencia **caveman** quando ela existir no ambiente (ex.: em `skills/` no Cursor ou em `~/.agents/skills/`) — menos tokens e comportamento alinhado. Sem essa instalação, esse trecho é ignorado (sem erro).

---

## Context-mode (recomendado)

**Projeto:** <https://github.com/mksglu/context-mode>

Complemento **opcional**, **fora** dos scripts `install/` — siga o passo a passo do próprio projeto.

**context-mode** é um servidor MCP que ajuda a **reduzir ruído no contexto** (por exemplo executando análises em sandbox e devolvendo só o essencial ao chat). Instale e configure o MCP no Cursor (ou no cliente que você usar) quando quiser esse fluxo.
