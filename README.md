# baladapp-ia-config

**Idioma deste README:** português do Brasil (pt-BR).

Repositório de **regras**, **comandos** e scripts de instalação para alinhar o assistente de IA ao **seu** fluxo (Ruby on Rails, TDD, convenções de **equipe**). O fluxo documentado é **um** `curl` para `install.sh` ou `upgrade.sh`: o script clona este repo, **baixa** o Karpathy a partir do [SKILL.md original](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md) (via **curl** + **python3** no clone) e aplica a configuração nas IDEs suportadas. **Requisitos comuns:** **git**, **curl** e **python3** (também para conversão `.mdc`→`.md` onde aplicável). Skills **Caveman** são opcionais (ver [Skills Caveman](#skills-caveman-recomendado)). Para **atualizar** o `main`, use [Atualizar](#atualizar).

## Instalação

A instalação é **sempre** este comando (**baixa** `install/install.sh` da branch `main` e executa):

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash
```

O script **clona** [eduardolagares/ia-config](https://github.com/eduardolagares/ia-config) em **`main`** para uma pasta temporária e aplica o que estiver definido no instalador (perguntas interativas no terminal).

Simular sem alterar **arquivos**:

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | bash -s -- --dry-run
```

Caveman sem pergunta (ex.: CI): `INSTALL_CAVEMAN=yes` antes do `curl` **não** chega ao `bash` do pipeline; use `curl ... | env INSTALL_CAVEMAN=yes bash`.

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

**`VERSION`:** arquivo na raiz com **uma linha** semver; deve coincidir com `baladapp_ia_config_version` no frontmatter de `rules/`, `commands/` e `skills/README.md`. Skills **geradas** pelo `install/lib/convert_ia_config.py` (Codex) e o `.mdc` Karpathy gerado no clone também recebem essa versão a partir deste arquivo.

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

**`install/lib/`** (suporte, não scripts de entrada): `convert_ia_config.py`, `karpathy-rules.sh`, `ide-sync.sh`, `caveman-install.sh`.

### `rules/`

Regras em `.mdc` (Cursor **Project Rules** / contexto por glob). No **frontmatter** YAML de cada arquivo versionado neste repo existe `baladapp_ia_config_version` (mesmo valor semver que `VERSION` na raiz — atualize os dois quando mudar o conjunto de regras).

As regras **deste repositório** usam o prefixo `baladapp-` no nome do **arquivo**; **regras de terceiros** instaladas pelo script (ex.: Karpathy, só no **seu** disco após o `install`) mantêm o nome estável `karpathy-guidelines.mdc`, **sem** esse prefixo. Cada **arquivo** da tabela abaixo documenta convenções para um tipo de código ou preocupação.

| Arquivo             | Tema |
|---------------------|------|
| `baladapp-caveman.mdc` | Modo caveman full (regra global). |
| `baladapp-clean_code_ruby.mdc` | Clean code e Rails em geral. |
| `baladapp-context-mode.mdc` | Uso de context-mode / análise sem inundar o contexto. |
| `baladapp-controllers.mdc` | Controllers. |
| `baladapp-implementation.mdc` | Alterações de código ↔ testes em sincronia. |
| `baladapp-ia-config-versioning.mdc` | Política de `VERSION` e `baladapp_ia_config_version` nos artefatos versionados. |
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

Comandos slash (Markdown) invocados no chat; descrevem fluxos longos para o agente seguir. O frontmatter inclui `baladapp_ia_config_version` (alinhado a `VERSION` na raiz).

| Arquivo    | Descrição resumida |
|------------|--------------------|
| `baladapp-commit.md` | Analisa diff/staging, mensagem curta em pt-BR, `git add` + `git commit` sem pedir confirmação. Comando: `/baladapp-commit`. |
| `baladapp-tdd-dev.md` | Fluxo TDD de implementação (RED/GREEN, menus, alinhado ao spec criado com `/baladapp-tdd-doc`). |
| `baladapp-tdd-doc.md` | Fluxo para documentar/**guiar** o trabalho TDD no spec. Comando: `/baladapp-tdd-doc`. |
| `baladapp-code-review.md` | Revisão **sênior** read-only (pt-BR). Comando: `/baladapp-code-review`. |

### `skills/`

No repositório existe apenas **`skills/README.md`** (metadados + `baladapp_ia_config_version`). O instalador **copia** a pasta `skills/` inteira para o Cursor; após aceitar **Caveman**, podem aparecer subpastas com `SKILL.md` (não versionadas aqui).

Depois de **rodar** o instalador e aceitar **Caveman** (ou `INSTALL_CAVEMAN=yes` no mesmo pipeline, ver [Instalação](#instalação)), as skills Caveman ficam nos diretórios que o script tiver configurado.

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

O ecossistema **Caveman** (modo compacto, commit/review/compress, cavecrew, …) **não está no histórico Git** deste repo. O instalador via **`curl`** sugere instalar esse toolkit no final (pergunta interativa). Sem pergunta: `curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh | env INSTALL_CAVEMAN=yes bash`. Fonte: [github.com/JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman).

**Por quê:** comandos como `/baladapp-tdd-dev` pedem a skill **caveman** quando existe em `skills/` — menos tokens e comportamento alinhado ao texto do comando. Se você **recusar** a instalação, o repositório continua só com `skills/README.md` (sem pasta Caveman em `skills/`); esse bloco é ignorado (sem erro).

---

## Context-mode (recomendado)

Complemento **opcional**, **fora** dos scripts `install/` — siga o passo a passo do próprio projeto.

**[context-mode](https://github.com/mksglu/context-mode)** é um servidor MCP que ajuda a **reduzir ruído no contexto** (por exemplo executando análises em sandbox e devolvendo só o essencial ao chat). Combina bem com a regra `rules/baladapp-context-mode.mdc` deste repositório: instale e configure o MCP no Cursor (ou no cliente que você usar) quando quiser esse fluxo.
