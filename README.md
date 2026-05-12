---
VERSION: "0.0.3"
description: "README do baladapp-ia-config — visão geral, instalação, atualização e skills opcionais."
---

# baladapp-ia-config

**Idioma deste README:** português do Brasil (pt-BR).

Repositório de **regras**, **comandos** e scripts de instalação para alinhar o assistente de IA ao **seu** fluxo (Ruby on Rails, TDD, convenções de **equipe**). O fluxo documentado é **um** `curl` para `install.sh` ou `upgrade.sh`: o script clona este repo, **baixa** o Karpathy a partir do [SKILL.md original](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md) (via **curl** + **python3** no clone) e aplica a configuração nas IDEs suportadas. **Requisitos comuns:** **git**, **curl** e **python3** (também para conversão `.mdc`→`.md` onde aplicável). O pacote de skills **Caveman** é **opcional** e **não** é instalado por estes scripts; veja [Skills Caveman (recomendado)](#skills-caveman-recomendado). Para **atualizar** o `main`, use [Atualizar](#atualizar).

## Instalação

A instalação é **sempre** este comando (**baixa** `install/install.sh` da branch `main` e executa):

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash
```

O script **clona** [eduardolagares/ia-config](https://github.com/eduardolagares/ia-config) em **`main`** para uma pasta temporária e aplica o que estiver definido no instalador (perguntas interativas no terminal). Skills de terceiros (ex.: **Caveman**) não fazem parte deste fluxo; instale-as à parte conforme [Skills Caveman (recomendado)](#skills-caveman-recomendado).

Simular sem alterar **arquivos**:

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash -s -- --dry-run
```

### Migração: você tinha symlinks no Cursor

Se você instalou uma versão antiga com symlinks em `~/.cursor/{rules,skills,commands}`:

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/fix-cursor-symlinks.sh | bash
```

Simular: `curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/fix-cursor-symlinks.sh | bash -s -- --dry-run`. Outro destino: `curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/fix-cursor-symlinks.sh | env CURSOR_HOME=/caminho/.cursor bash`. Depois, reinicie o Cursor.

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

---

## Comandos

Comandos slash (Markdown em `commands/`) que o instalador copia para a IDE; ficam disponíveis no chat após o `install.sh`/`upgrade.sh`.

| Comando | O que faz |
|---------|-----------|
| `/baladapp-commit` | Lê `git diff`/staging, gera mensagem curta em pt-BR e executa `git add` + `git commit` sem pedir confirmação. |
| `/baladapp-tdd-doc` | Monta o spec de requisitos + TDD (RED/GREEN) em markdown, sem implementar código no chat. |
| `/baladapp-tdd-dev` | Ciclo TDD de implementação (RED/GREEN) por RF ou por fase, com menu de iteração; segue o spec criado por `/baladapp-tdd-doc`. |
| `/baladapp-code-review` | Revisão sênior **read-only** em pt-BR: correção, fluxos, segurança, contratos, persistência, concorrência. |

---

## Regras

Regras em `.mdc` (Cursor **Project Rules** / contexto por glob) que o instalador copia para a IDE. Todas começam com o prefixo `baladapp-` e ficam em `rules/` neste repo.

| Arquivo | Tema |
|---------|------|
| `baladapp-clean_code_ruby.mdc` | Clean code Rails — time zones, erros, fronteiras AR; sintaxe/nomes → `baladapp-ruby.mdc`. |
| `baladapp-controllers.mdc` | Controllers magros — Pundit, strong params, REST, use cases / queries. |
| `baladapp-implementation.mdc` | Edits mantêm testes em sincronia — achar spec contraparte, atualizar contratos, rodar testes focados. |
| `baladapp-migrations.mdc` | Migrations Rails — gerador, prefixo de versão, reversibilidade, índices, FKs, Postgres seguro. |
| `baladapp-models.mdc` | Models AR magros — validações, scopes, enums; orquestração fora. |
| `baladapp-query_objects.mdc` | Query objects — read-only, `relation:` / `@relation`, `self.call`, YARD. |
| `baladapp-rule_objects.mdc` | Rule objects — uma pergunta de domínio, `#result` primitivo, read-only. |
| `baladapp-ruby.mdc` | Estilo Ruby — kwargs, nomes, fluxo de controle, sem meta desnecessária. |
| `baladapp-use_cases.mdc` | Use cases — `Dry::Monads::Result`, namespace por domínio, sem `dry-transaction`. |
| `baladapp-views.mdc` | Views — ViewComponent, presenters, I18n, templates burros. |
| `baladapp-writting-tests-rails.mdc` | Testes Minitest — TDD, naming, asserções de negócio, isolamento. |

> A regra `karpathy-guidelines.mdc` **não** está versionada neste repo: o `install/` baixa o [SKILL.md original](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md) e converte para `.mdc` durante a instalação.

---

## Skills Caveman (recomendado)

**Projeto:** <https://github.com/JuliusBrussee/caveman>

O ecossistema **Caveman** (modo compacto, commit/review/compress, cavecrew, …) é um **pacote de skills de terceiros** que **recomendamos**, mas **não** faz parte do `install.sh` nem do `upgrade.sh` deste repositório. **Instale e atualize pelo próprio projeto Caveman** (instruções e releases no repositório oficial).

**Por quê:** comandos como `/baladapp-tdd-dev` referem-se à skill **caveman** quando ela existir no ambiente (ex.: em `skills/` no Cursor ou em `~/.agents/skills/` no Codex) — menos tokens e comportamento alinhado ao texto do comando. Sem essa instalação, esse trecho dos comandos é ignorado (sem erro).

---

## Context-mode (recomendado)

**Projeto:** <https://github.com/mksglu/context-mode>

Complemento **opcional**, **fora** dos scripts `install/` — siga o passo a passo do próprio projeto.

**context-mode** é um servidor MCP que ajuda a **reduzir ruído no contexto** (por exemplo executando análises em sandbox e devolvendo só o essencial ao chat). Instale e configure o MCP no Cursor (ou no cliente que você usar) quando quiser esse fluxo.
