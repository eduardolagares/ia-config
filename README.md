# ia-config

Repositório de **regras** (Cursor), **comandos** e scripts de instalação para alinhar o assistente de IA ao teu fluxo (Ruby on Rails, TDD, convenções de equipa). O instalador descarrega **obrigatoriamente** `rules/karpathy-guidelines.mdc` a partir do projeto **[andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills)** (precisa de **curl**). **Claude Code, Antigravity e Codex** usam **python3** em `install/lib/convert_ia_config.py` para converter `.mdc`→`.md` (ex. `globs`→`paths`) e gerar skills/workflows nos paths certos de cada IDE. O **Cursor** e os ficheiros raiz do **Codex/Antigravity** usam **cópias** (sem symlinks). As skills **Caveman** continuam opcionais — no fim o script **sugere** instalá-las (pergunta interativa — ver abaixo). Para atualizar Karpathy, Caveman e cópias convertidas, segue a secção **[Upgrade (Karpathy e Caveman)](#upgrade-karpathy-e-caveman)**.

## Instalação

### Caminho recomendado: `install/install.sh`

Não precisas de ter o repositório já clonado. O script **clona** o ia-config para uma **pasta temporária**, obtém o Karpathy no clone, e **copia** os ficheiros para os destinos de cada ferramenta.

**Requisitos:** **git**, **curl**; **python3** se escolheres Claude, Antigravity ou Codex.

```bash
chmod +x install/install.sh   # só se tiveres um clone local
bash install/install.sh
```

Ou descarregar o script e correr (evita problemas com `curl | bash` e variáveis de ambiente):

```bash
curl -fsSL https://raw.githubusercontent.com/eduardolagares/ia-config/main/install/install.sh -o /tmp/ia-config-install.sh
bash /tmp/ia-config-install.sh
```

Variáveis como `IA_CONFIG_REPO_URL` têm de estar visíveis para o **mesmo** processo `bash` que corre o script (por exemplo `IA_CONFIG_REPO_URL=https://github.com/me/ia-config.git bash /tmp/ia-config-install.sh`), não apenas antes de um `curl` num pipeline.

O instalador pergunta:

1. **URL e ramo** do repositório (há valores por omissão).
2. **Destino:** pastas **globais** (`~/.cursor`, `~/.claude`, …) ou **projeto** (`<projeto>/.cursor` e `<projeto>/.claude`). Antigravity e Codex mantêm-se em **`~/.gemini`** e **`~/.codex`** (e skills em `~/.agents/skills` por omissão), mesmo no modo projeto.
3. **Quais agentes:** Cursor, Claude Code, Antigravity, Codex (pergunta sim/não a cada um).

Variáveis úteis:

| Variável | Efeito |
|----------|--------|
| `IA_CONFIG_REPO_URL` | URL git (predefinição aponta para este repo público). |
| `IA_CONFIG_BRANCH` | Ramo (predef.: `main`). |
| `IA_CONFIG_SKIP_CLONE=1` + `IA_CONFIG_REPO_ROOT=/path` | Só para desenvolvimento: usa um clone já existente em vez de clonar para `/tmp`. |

Simular sem alterar ficheiros:

```bash
./install/install.sh --dry-run
```

### Migração: tinhas symlinks no Cursor

Se instalaste uma versão antiga com symlinks em `~/.cursor/{rules,skills,commands}`, corre a partir da raiz de um clone deste repo:

```bash
bash install/fix-cursor-symlinks.sh
```

O script resolve cada symlink, copia o conteúdo da pasta de destino para um diretório real e remove o link. Pastas que já forem diretórios normais não são alteradas. Simular: `bash install/fix-cursor-symlinks.sh --dry-run`. Outro destino (não `~/.cursor`): `CURSOR_HOME=/caminho/.cursor bash install/fix-cursor-symlinks.sh`. Depois, reinicia o Cursor.

### Instalação por agente (clone local)

1. **Clona** este repositório para um path estável (ex.: `~/projetos/ia-config`).

2. **Dá permissão de execução** aos scripts (só na primeira vez):

   ```bash
   chmod +x install/install.sh install/fix-cursor-symlinks.sh install/cursor.sh install/claude.sh install/antigravity.sh install/codex.sh
   ```

3. **Escolhe o ambiente** e corre o instalador correspondente a partir da raiz do repo (ou define `IA_CONFIG_REPO_ROOT` se correres a partir de outro sítio):

   | Ferramenta    | Comando                 | Efeito |
   |---------------|-------------------------|--------|
   | **Cursor**    | `./install/cursor.sh`   | **Copia** `rules`, `skills` e `commands` para `~/.cursor/` (ou `CURSOR_HOME`), substituindo destinos existentes. |
   | **Claude Code** | `./install/claude.sh` | Escreve `~/.claude/rules/*.md` (conversão de `rules/*.mdc`), `~/.claude/commands/*.md` (paths no texto apontam para `~/.claude/commands/`) e copia `skills/` para `~/.claude/skills/`. Usa `CLAUDE_CONFIG_DIR` se estiver definido — [documentação](https://code.claude.com/en/env-vars). |
   | **Antigravity** | `./install/antigravity.sh` | **Copia** `GEMINI.md` e `AGENTS.md` para `~/.gemini/` (ou `GEMINI_HOME`). Além disso: `antigravity/ia-config/rules/*.md`, `antigravity/global_workflows/*.md` e `antigravity/skills/`. Aviso: `GEMINI.md` pode coincidir com o [Gemini CLI](https://github.com/google-gemini/gemini-cli) no mesmo path. |
   | **Codex**     | `./install/codex.sh`    | **Copia** `~/.codex/AGENTS.md` a partir de `codex/AGENTS.md`. Gera skills em `~/.agents/skills` (ou `AGENTS_SKILLS_ROOT`): `ia-rule-*` e `command-*` a partir de `rules/` e `commands/`, mais cópia de `skills/` do repo. [Doc Codex](https://developers.openai.com/codex/guides/agents-md). |

   **Antes das cópias**, o script obtém **`rules/karpathy-guidelines.mdc`** do ramo `main` de [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (ficheiro `.cursor/rules/karpathy-guidelines.mdc` no upstream). É **obrigatório** para a instalação completar; não está versionado neste repo (`.gitignore`). URL alternativa: variável `KARPATHY_GUIDELINES_URL`.

   No **final**, o instalador **sugere** as skills **Caveman**: aparece uma pergunta (predefinição *não*) sobre **instalar** esse toolkit. Se aceitares, corre um `git clone` shallow de [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) e copia-se `skills/` desse repo para `skills/` do clone em uso (ficheiros cobertos pelo `.gitignore`). Exige **git** instalado.

   **Sem prompt interativo** (CI ou scripts):

   ```bash
   INSTALL_CAVEMAN=yes ./install/cursor.sh
   ./install/claude.sh --with-caveman
   ./install/cursor.sh --without-caveman   # não pergunta nem instala
   ```

   **Repo alternativo:** `CAVEMAN_REPO_URL=https://... ./install/cursor.sh`

4. **Simula** sem alterar nada:

   ```bash
   ./install/cursor.sh --dry-run
   ./install/claude.sh --dry-run
   ./install/antigravity.sh --dry-run
   ./install/codex.sh --dry-run
   ./install/cursor.sh --upgrade --dry-run
   ```

5. **Reinicia** o Cursor, o Claude Code, o Antigravity ou o Codex para garantir que carrega a configuração nova.

**Requisitos:** **curl** (Karpathy), **git** (Caveman opcional), **python3** (Claude, Antigravity, Codex — conversão na instalação).

---

## Upgrade (Karpathy e Caveman)

Serve para **voltar a obter** o `karpathy-guidelines.mdc` e as pastas **Caveman** em `skills/` a partir dos repos upstream. No **Cursor**, `--upgrade` **não** substitui as cópias em `~/.cursor/` (só Karpathy + Caveman no clone em uso). Em **Claude Code**, **Antigravity** e **Codex**, o mesmo comando **volta a sincronizar** as rules/commands/skills convertidas para os diretórios da IDE (além de Karpathy e Caveman). Corre à **raiz do clone** em que queres atualizar o ficheiro Karpathy (ou exporta `IA_CONFIG_REPO_ROOT`).

### Comandos

**Cursor**

```bash
cd /caminho/para/ia-config
./install/cursor.sh --upgrade
```

**Claude Code** (usa `CLAUDE_CONFIG_DIR` se estiver definido)

```bash
cd /caminho/para/ia-config
./install/claude.sh --upgrade
```

### O que cada parte faz

| Componente | O que o `--upgrade` faz |
|------------|-------------------------|
| **Karpathy** | Descarga de novo `rules/karpathy-guidelines.mdc` a partir do ramo `main` de [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (precisa de **curl**). Override da URL: `KARPATHY_GUIDELINES_URL=...`. |
| **Caveman** | Novo `git clone` shallow de [caveman](https://github.com/JuliusBrussee/caveman) e cópia de `skills/` para `skills/` do teu clone (precisa de **git**). Surge a pergunta **«Atualizar skills Caveman?»** (predefinição *não*). |
| **Sync IDE** (Claude / Antigravity / Codex) | Volta a gerar ficheiros convertidos em `~/.claude/…`, `~/.gemini/antigravity/…` ou `~/.agents/skills/` conforme o script (precisa de **python3**). |

### Sem perguntas (só Caveman)

```bash
INSTALL_CAVEMAN=yes ./install/cursor.sh --upgrade
```

### Só Karpathy (sem atualizar Caveman)

```bash
./install/cursor.sh --upgrade --without-caveman
```

(Neste caso o Karpathy **é** atualizado; o Caveman **não** é tocado.)

### Simular

```bash
./install/cursor.sh --upgrade --dry-run
./install/claude.sh --upgrade --dry-run
./install/antigravity.sh --upgrade --dry-run
./install/codex.sh --upgrade --dry-run
```

---

## Conteúdo do repositório

### `install/`

Scripts bash que descarregam **obrigatoriamente** `karpathy-guidelines.mdc`, **copiam** ficheiros para o **Cursor** (`rules`, `skills`, `commands` em `CURSOR_HOME`), e para **Claude / Antigravity / Codex** escrevem ou copiam ficheiros nas pastas esperadas por cada ferramenta (com conversão via `install/lib/convert_ia_config.py`). **Antigravity** e **Codex** copiam `GEMINI.md`/`AGENTS.md` ou `AGENTS.md` para o home da ferramenta; o resto é cópia/geração. No fim **sugerem** as skills Caveman.

| Ficheiro      | Função |
|---------------|--------|
| `install.sh`  | Instalador interativo: clone temporário, perguntas (global/projeto, agentes), chama os scripts por agente. |
| `fix-cursor-symlinks.sh` | Migra `~/.cursor/{rules,skills,commands}` de symlinks para pastas reais. |
| `cursor.sh`   | Instalação para Cursor (cópias). |
| `claude.sh`   | Claude Code; `CLAUDE_CONFIG_DIR`; gera `rules/`, `commands/`, `skills/` sob `~/.claude/`. |
| `antigravity.sh` | Google Antigravity: cópia de `GEMINI.md` e `AGENTS.md`; cópias em `antigravity/ia-config/rules`, `global_workflows`, `skills`. |
| `codex.sh`    | Codex CLI: cópia de `AGENTS.md`; skills em `AGENTS_SKILLS_ROOT` (predef. `~/.agents/skills`). |
| `lib/karpathy-rules.sh` | `curl` do `.mdc` Karpathy a partir de [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills); **obrigatório**. |
| `lib/caveman-install.sh` | Clone shallow do upstream e cópia para `skills/`; opcional (pergunta no fim). |
| `lib/ide-sync.sh` | Funções bash partilhadas para sincronizar rules/commands/skills. |
| `lib/convert_ia_config.py` | Conversões `.mdc`→`.md`, reescrita de paths em comandos, skills Codex. |

### `rules/`

Regras em `.mdc` (Cursor **Project Rules** / contexto por glob). As regras **deste repositório** usam o prefixo `baladapp-` no nome do ficheiro; **regras de terceiros** instaladas pelo script (ex.: Karpathy) mantêm o nome original do upstream, **sem** esse prefixo. Cada ficheiro da tabela abaixo documenta convenções para um tipo de código ou preocupação.

| Ficheiro             | Tema |
|----------------------|------|
| `baladapp-ruby.mdc`           | Convenções de linguagem Ruby. |
| `baladapp-clean_code_ruby.mdc` | Clean code e Rails em geral. |
| `baladapp-models.mdc`         | Models Active Record. |
| `baladapp-controllers.mdc`    | Controllers. |
| `baladapp-views.mdc`          | Views / templates. |
| `baladapp-migrations.mdc`     | Migrations e alterações de schema. |
| `baladapp-writting-tests-rails.mdc` | Escrita de testes Rails (Minitest). |
| `baladapp-query_objects.mdc`  | Query objects. |
| `baladapp-rule_objects.mdc`   | Rule objects / objetos de regra de domínio. |
| `baladapp-use_cases.mdc`      | Domain use cases (Dry::Monads, paths under `use_cases/`). |
| `baladapp-context-mode.mdc`   | Uso de context-mode / análise sem inundar o contexto. |
| `baladapp-implementation.mdc`  | Alterações de código ↔ testes em sincronia. |
| `baladapp-caveman.mdc`       | Modo caveman full (regra global). |
| `karpathy-guidelines.mdc` | **Externo (sem prefixo `baladapp-`):** obtido pelo `install/` a partir de [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills); não commitado. Diretrizes Karpathy para o agente. |

### `commands/`

Comandos slash (Markdown) invocados no chat; descrevem fluxos longos para o agente seguir.

| Ficheiro    | Descrição resumida |
|-------------|--------------------|
| `baladapp-commit.md` | Analisa diff/staging, mensagem curta em pt-BR, `git add` + `git commit` sem pedir confirmação. Comando: `/baladapp-commit`. |
| `baladapp-tdd-dev.md` | Fluxo TDD de implementação (RED/GREEN, menus, alinhado ao spec criado com `/baladapp-tdd-doc`). |
| `baladapp-tdd-doc.md` | Fluxo para documentar/guionar o trabalho TDD no spec. Comando: `/baladapp-tdd-doc`. |
| `baladapp-code-review.md` | Revisão sénior read-only (pt-BR). Comando: `/baladapp-code-review`. |

### `skills/`

No Git existe apenas `skills/.gitkeep` — a pasta existe para o instalador poder **copiar** skills para `~/.cursor/skills` (ou equivalente em projeto).

Depois de correres o instalador e aceitares **Caveman** (ou `INSTALL_CAVEMAN=yes`), aparecem no **clone em uso** pastas em `skills/` copiadas do upstream (`caveman`, `caveman-commit`, etc.); continuam **fora do controlo de versão** (`.gitignore`). O Cursor recebe **cópias** dessas pastas em `CURSOR_HOME/skills/`.

### `hooks/` e `prompts/`

Pastas reservadas (`hooks/.gitkeep`, `prompts/.gitkeep`) para poderes acrescentar localmente hooks ou prompts sem alterar a estrutura base do projeto.

### `.gitignore`

Ignora `rules/karpathy-guidelines.mdc` (descarregado na instalação) e paths de **skills de terceiros** sob `skills/`.

---

## Skills Caveman (recomendado)

O ecossistema **Caveman** (modo compacto, commit/review/compress, cavecrew, …) **não está no histórico Git** deste repo. O **instalador sugere** instalar esse toolkit no final (pergunta interativa); também podes forçar com `--with-caveman` ou `INSTALL_CAVEMAN=yes`. Fonte: [github.com/JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman).

**Porquê:** comandos como `/baladapp-tdd-dev` pedem a skill **caveman** quando existe em `skills/` — menos tokens e comportamento alinhado ao texto do comando. Se recusares a instalação e a pasta `skills/` ficar só com `.gitkeep`, esse bloco é ignorado (sem erro).

---

## Context-mode (recomendado)

Complemento **opcional**, **fora** dos scripts `install/` — segue o passo a passo do próprio projeto.

**[context-mode](https://github.com/mksglu/context-mode)** é um servidor MCP que ajuda a **reduzir ruído no contexto** (por exemplo executando análises em sandbox e devolvendo só o essencial ao chat). Combina bem com a regra `rules/baladapp-context-mode.mdc` deste repositório: instala e configura o MCP no Cursor (ou no cliente que suportes) quando quiseres esse fluxo.
