---
VERSION: "1.29.0"
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

No **upgrade** (e na instalação), o instalador **apaga** `{rules,skills}/eduardolagares/` no destino e cola de novo a partir do repo — ficheiros removidos no `main` deixam de existir no destino. Também remove artefactos legados de layouts antigos.

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
| `escrever-tarefa` | Entrevista (grill-me em `~/.agents`, `~/.cursor` ou `~/.claude`); texto livre ou ficheiro (referência ou continuar `docs/tarefas/*.md`). |
| `gerar-plano-de-implementacao` | No projeto a alterar: avalia estrutura de código + grill-me; cobre RFs/UCs/Impactos com nomes concretos; grava em `docs/planos-de-implementacao/`. |
| `planejar-tenant` | Plan enxuto de tenant (`docs/plans/<id>/`) neste clone; brief/estilo/negócio/logo na fonte do ingressos. Entrevista só na 1ª vez. Não implementa nem commita. |
| `spec-implementer` | Doc Cenário/RF/UC → código + testes; plano em `docs/specs/`; pergunta só o crítico; nunca reporta pronto com testes vermelhos. |
| `criar-tarefa-no-monday` | Publica no Monday documento funcional pronto (item, doc, subtarefas, branch); entrevista só parâmetros Monday; Mermaid → PNG. |
| `tdd-doc` | **Depreciada** — use `spec-implementer` (ou `escrever-tarefa`). Legado: spec TDD em markdown, sem código. |
| `tdd-dev` | **Depreciada** — use `spec-implementer`. Legado: ciclo TDD RED/GREEN por RF/fase/completo; segue `tdd-doc`. |
| `code-review` | Revisão sénior **read-only** em pt-BR: correção, fluxos, segurança, contratos, persistência, concorrência. |
| `refatorar-codigo` | Refatora o diff (branch vs `master`, alterações locais ou paths indicados) para Clean & Short Code; aplica em disco, mantém comportamento. |
| `monday-task-info` | Passo 1 de `revisar-tarefa`: contexto Monday só via MCP da IDE. |
| `revisar-tarefa` | Fluxo Monday em 8 passos: contexto, requisitos, diff GitLab (MCP da IDE), code review, verificação, doc Revisar código, avaliação e pós-avaliação (MRs + coluna **Ação** Concluir/Rejeitar). Substitui `agendar-revisao-tarefa` e `executar-revisao-tarefa`. |

No **Cursor**, `/revisar-tarefa` exige **Monday** e **GitLab** ligados em **Settings → MCP** (passo 1 via `monday-task-info`; passos 3 e 8 via MCP GitLab da IDE — sem tokens nem scripts de API).

---

## Regras (`rules/eduardolagares/`)

Regras `.mdc` copiadas para `rules/eduardolagares/` no destino. **Todas** usam **`alwaysApply: true`** — carregadas em todo chat/agente.

| Arquivo | Tema |
|---------|------|
| `domain-layer.mdc` | Router da camada de domínio — query vs use case vs rule vs infrastructure vs scope. |
| `responsibilities.mdc` | Uma responsabilidade por classe/método; layers + estrutura do projeto; extrair só com motivo. |
| `git-branch-naming.mdc` | Nome de branch git — `dev-<kebab-case>`; sem `feat/`/`fix/`/etc. |
| `infrastructure.mdc` | Infrastructure de domínio — I/O, gems e integrações locais em `app/domains/**/infrastructure/`. |
| `naming-rails.mdc` | Naming Rails — ficheiros, classes, métodos; rule = pergunta; query = resultado + `Query`. |
| `ruby.mdc` | Estilo Ruby — kwargs, fluxo de controle, sem meta desnecessária; naming → `naming-rails.mdc`. |
| `clean_code_ruby.mdc` | Clean code Rails — time zones, erros, fronteiras AR. |
| `controllers.mdc` | Controllers magros — Pundit, strong params, REST; integração/request obrigatória e limitada. |
| `implementation.mdc` | Edits mantêm testes em sincronia — integração/request por tela (status + render); contratos; testes focados. |
| `migrations.mdc` | Migrations Rails — gerador, versão, reversibilidade, índices, FKs, naming de colunas. |
| `models.mdc` | Models AR magros — validações, scopes, enums; orquestração fora. |
| `query_objects.mdc` | Query objects — nome = resultado + `Query`, `relation:` / `@relation`, `self.call`, YARD. |
| `rule_objects.mdc` | Rule objects — pergunta de domínio em PT, `#result` primitivo, read-only. |
| `use_cases.mdc` | Use cases — `Dry::Monads::Result`, `#call` como roteiro linear, sem `dry-transaction`. |
| `views.mdc` | Views — ViewComponent, presenters, I18n, templates burros. |
| `writting-tests-rails.mdc` | Testes Minitest — estrutura; integração/request obrigatória e limitada; força → `test-quality-rails`. |
| `test-quality-rails.mdc` | Critério de força — comportamento de produto, naming PT, anti-padrões; não cobertura de linha. |
| `screen-integration-tests.mdc` | Tela criada/alterada → teste de integração/request com um status HTTP deliberado. |
| `rails-test-submodule-readonly.mdc` | Passagem só de testes — produção read-only; só `test/` muda. |
| `writting-tests-react.mdc` | Specs Vitest + RTL — layout `js-tests/`, naming, agrupamento, isolamento. |
| `vitest-setup.mdc` | Bootstrap Vitest na raiz do host (config, aliases, scripts) — não specs. |
| `karpathy-guidelines.mdc` | Diretrizes comportamentais Karpathy — gerado no install (não versionado no Git). |

> A regra `karpathy-guidelines.mdc` **não** está versionada neste repo: o `install/` baixa o [SKILL.md original](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md), converte para `.mdc` com `alwaysApply: true` e grava em `{dest}/rules/eduardolagares/` **após** copiar as rules versionadas.

O **upgrade** remove skills legadas `agendar-revisao-tarefa` e `executar-revisao-tarefa` (layouts flat ou em `skills/eduardolagares/`) antes de sincronizar o pacote actual.

---

## Skills Caveman (recomendado)

**Projeto:** <https://github.com/JuliusBrussee/caveman>

O ecossistema **Caveman** (modo compacto, commit/review/compress, cavecrew, …) é um **pacote de skills de terceiros** que **recomendamos**, mas **não** faz parte do `install.sh` nem do `upgrade.sh` deste repositório. **Instale e atualize pelo próprio projeto Caveman** (instruções e releases no repositório oficial).

**Por quê:** skills do pacote (ex. legado `tdd-dev`) podem referenciar **caveman** quando existir no ambiente — menos tokens e comportamento alinhado. Sem essa instalação, esse trecho é ignorado (sem erro).

---

## Context-mode (recomendado)

**Projeto:** <https://github.com/mksglu/context-mode>

Complemento **opcional**, **fora** dos scripts `install/` — siga o passo a passo do próprio projeto.

**context-mode** é um servidor MCP que ajuda a **reduzir ruído no contexto** (por exemplo executando análises em sandbox e devolvendo só o essencial ao chat). Instale e configure o MCP no Cursor (ou no cliente que você usar) quando quiser esse fluxo.
