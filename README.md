---
VERSION: "0.0.1"
description: "README do baladapp-ia-config — visão geral, instalação, atualização e mapa do repositório."
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

## Conteúdo do repositório

**`VERSION`:** arquivo na raiz com **uma linha** semver; deve coincidir com o atributo `VERSION` no frontmatter de `rules/`, `commands/` e `skills/README.md`. Skills **geradas** pelo `install/lib/convert_ia_config.py` (Codex) e o `.mdc` Karpathy gerado no clone também recebem essa versão a partir deste arquivo.

### `install/`

Scripts chamados por **`install.sh`** e **`upgrade.sh`** (não é necessário rodar nada além do `curl` documentado nas seções [Instalação](#instalação) e [Atualizar](#atualizar)).

| Arquivo | Função |
|---------|--------|
| `install.sh` | Instalador interativo: `curl … | bash`; clona **eduardolagares/ia-config** (`main`) para pasta temporária e orquestra o resto. |
| `upgrade.sh` | Atualização pelo mesmo padrão de `curl`; ver [Atualizar](#atualizar). |
| `fix-cursor-symlinks.sh` | Migração pontual de symlinks no Cursor; ver [Migração](#migração-você-tinha-symlinks-no-cursor). |
| `cursor.sh` | Instalação / upgrade para Cursor (cópias em `CURSOR_HOME`). |
| `claude.sh` | Instalação / upgrade para Claude Code (`CLAUDE_CONFIG_DIR`). |
| `antigravity.sh` | Instalação / upgrade para Antigravity (`GEMINI_HOME`). |
| `codex.sh` | Instalação / upgrade para Codex (`CODEX_HOME`, `AGENTS_SKILLS_ROOT`). |

**`install/lib/`** (suporte, não scripts de entrada): `convert_ia_config.py`, `karpathy-rules.sh`, `ide-sync.sh`.

### `.cursor/rules/` (manutenção deste repo)

Regras usadas **só** ao desenvolver **este** repositório no Cursor; **não** entram na pasta `rules/` nem são copiadas pelo `install/` para consumidores do pacote.

| Ficheiro | Função |
|----------|--------|
| `versioning.mdc` | Política do arquivo `VERSION` e do atributo `VERSION` no frontmatter dos artefatos publicados em `rules/`, `commands/`, `skills/`. |

### `rules/`

Regras em `.mdc` (Cursor **Project Rules** / contexto por glob). No **frontmatter** YAML de cada arquivo versionado neste repo existe o atributo `VERSION` (mesmo valor semver do arquivo `VERSION` na raiz — atualize os dois quando mudar o conjunto de regras).

As regras **deste repositório** usam o prefixo `baladapp-` no nome do **arquivo**; **regras de terceiros** instaladas pelo script (ex.: Karpathy, só no **seu** disco após o `install`) mantêm o nome estável `karpathy-guidelines.mdc`, **sem** esse prefixo. Cada **arquivo** da tabela abaixo documenta convenções para um tipo de código ou preocupação.

| Arquivo             | Tema |
|---------------------|------|
| `baladapp-clean_code_ruby.mdc` | Clean code e Rails em geral. |
| `baladapp-controllers.mdc` | Controllers. |
| `baladapp-implementation.mdc` | Alterações de código ↔ testes em sincronia. |
| `baladapp-migrations.mdc` | Migrations e alterações de schema. |
| `baladapp-models.mdc` | Models Active Record. |
| `baladapp-query_objects.mdc` | Query objects. |
| `baladapp-rule_objects.mdc` | Rule objects / objetos de regra de domínio. |
| `baladapp-ruby.mdc` | Convenções de linguagem Ruby. |
| `baladapp-use_cases.mdc` | Domain use cases (Dry::Monads, paths under `use_cases/`). |
| `baladapp-views.mdc` | Views / templates. |
| `baladapp-writting-tests-rails.mdc` | Escrita de testes Rails (Minitest). |
| `karpathy-guidelines.mdc` | **Não** está neste repositório. O `install/` **baixa** o [SKILL.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md) do [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), converte para `.mdc` no clone e segue o pipeline habitual. URL raw alternativa: variável `KARPATHY_GUIDELINES_URL`. |

### `commands/`

Comandos slash (Markdown) invocados no chat; descrevem fluxos longos para o agente seguir. O frontmatter inclui o atributo `VERSION` (alinhado ao arquivo `VERSION` na raiz).

| Arquivo    | Descrição resumida |
|------------|--------------------|
| `baladapp-commit.md` | Analisa diff/staging, mensagem curta em pt-BR, `git add` + `git commit` sem pedir confirmação. Comando: `/baladapp-commit`. |
| `baladapp-tdd-dev.md` | Fluxo TDD de implementação (RED/GREEN, menus, alinhado ao spec criado com `/baladapp-tdd-doc`). |
| `baladapp-tdd-doc.md` | Fluxo para documentar/**guiar** o trabalho TDD no spec. Comando: `/baladapp-tdd-doc`. |
| `baladapp-code-review.md` | Revisão **sênior** read-only (pt-BR). Comando: `/baladapp-code-review`. |

### `skills/`

No repositório existe apenas **`skills/README.md`** (metadados + atributo `VERSION`). O instalador **copia** a pasta `skills/` inteira para os destinos configurados. Subpastas com `SKILL.md` que **você** adicionar localmente (por exemplo após instalar o **Caveman** por fora) são copiadas junto; pastas típicas de terceiros ficam no `.gitignore` deste repo (ver secção `.gitignore` abaixo).

### `antigravity/`

| Arquivo | Função |
|---------|--------|
| `GEMINI.md` | Copiado para o home Antigravity pelo `install/antigravity.sh`. |
| `AGENTS.md` | Idem. |

### `codex/`

| Arquivo | Função |
|---------|--------|
| `AGENTS.md` | Copiado para `CODEX_HOME` pelo `install/codex.sh`. |

### `hooks/` e `prompts/`

Cada pasta contém só **`hooks/.gitkeep`** e **`prompts/.gitkeep`** (reservadas para você adicionar arquivos localmente sem mudar a estrutura base).

### `.gitignore`

Comentário sobre o Karpathy gerado no clone; entradas atuais ignoram pastas de skills de terceiros sob `skills/`: `skills/caveman/`, `skills/caveman-*/`, `skills/cavecrew/`, `skills/compress/`, `skills/find-skills/`.

---

## Skills Caveman (recomendado)

O ecossistema **[Caveman](https://github.com/JuliusBrussee/caveman)** (modo compacto, commit/review/compress, cavecrew, …) é um **pacote de skills de terceiros** que **recomendamos**, mas **não** faz parte do `install.sh` nem do `upgrade.sh` deste repositório. **Instale e atualize pelo próprio projeto Caveman** (instruções e releases no repositório oficial).

**Por quê:** comandos como `/baladapp-tdd-dev` referem-se à skill **caveman** quando ela existir no ambiente (ex.: em `skills/` no Cursor ou em `~/.agents/skills/` no Codex) — menos tokens e comportamento alinhado ao texto do comando. Sem essa instalação, esse trecho dos comandos é ignorado (sem erro).

---

## Context-mode (recomendado)

Complemento **opcional**, **fora** dos scripts `install/` — siga o passo a passo do próprio projeto.

**[context-mode](https://github.com/mksglu/context-mode)** é um servidor MCP que ajuda a **reduzir ruído no contexto** (por exemplo executando análises em sandbox e devolvendo só o essencial ao chat). Instale e configure o MCP no Cursor (ou no cliente que você usar) quando quiser esse fluxo.
