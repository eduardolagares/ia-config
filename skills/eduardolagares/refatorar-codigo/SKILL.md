---
name: refatorar-codigo
description: >-
  Refatora código Ruby on Rails do diff (branch vs master, alterações locais ou
  paths indicados) para Clean & Short Code, mantendo comportamento e convenções
  do projeto. Use com /refatorar-codigo, "refatorar diff", "refatorar código"
  ou pedidos de limpeza/encurtamento do código alterado.
disable-model-invocation: true
VERSION: "1.1.0"
---

# refatorar-codigo

**Pacote:** `skills/eduardolagares/refatorar-codigo/` — instalada pelo `install/` em `{destino}/skills/eduardolagares/refatorar-codigo/` (Cursor ou `~/.agents`).

## Papel

Atue como um desenvolvedor Ruby on Rails Sênior e especialista em refatoração de código.

Seu objetivo é analisar as alterações feitas no branch atual em relação à branch `master` (o diff fornecido abaixo) e refatorar esse código para torná-lo limpo, legível e performático, mantendo estritamente a mesma funcionalidade original e respeitando as convenções do projeto. Legível vem antes de curto: código menor com nomes vagos é pior que o original.

## Obter o escopo (ordem fixa)

1. **Paths indicados pelo utilizador** — refatorar só esses ficheiros (e código diretamente impactado).
2. **Alterações locais não comitadas** — `git status` + `git diff` (staged e unstaged).
3. **Diff branch vs `master`** — `git diff master...HEAD` (ou `master..HEAD` se o repo usar merge commits; preferir `...` para comparar com o merge-base).

Se nenhuma fonte tiver alterações → parar e pedir paths ou confirmar branch/base.

Ler `rules/eduardolagares/**` (instaladas em `~/.cursor/rules/eduardolagares/`), `.cursor/rules/`, `AGENTS.md` e convenções observáveis no código antes de refatorar.

## Diretrizes de qualidade (obrigatórias)

1. **Foco no Diff:** Refatore apenas o código que sofreu alterações ou que está diretamente impactado pelas mudanças entre as branches.
2. **Camadas do projeto:** Se o código modificado estiver inflando Models ou Controllers, extraia para a layer certa de `domain-layer.mdc` (query, use case, rule, infrastructure, presenter). Nunca `*Service`.
3. **Nomes primeiro:** Renomear classe, método ou variável do diff que reprova no § Teste do nome de `naming-rails.mdc` é refatoração válida e prioritária — vale mais que encurtar.
4. **Responsabilidade única:** Métodos com um efeito só. **Só extraia** um método privado se existir um nome mais claro que o próprio código extraído; se o único nome possível é vago (`processar`, `tratar`, `validar_kwargs`), deixe inline.
5. **Idiomas do Ruby:** Use cláusulas de guarda (guard clauses), memoization (`||=`) e métodos nativos de enumerable quando deixam o código mais legível — não só mais curto.
6. **Performance:** Garanta que as novas alterações não introduzam queries N+1 ou alocações de memória desnecessárias.

## Modo de execução

- **Aplicar refatoração em disco** — esta skill implementa; não limitar-se a sugestões no chat.
- **Escopo mínimo** — não refatorar código adjacente fora do diff/impacto directo.
- **Sem mudança de comportamento** — mesma API pública, mesmos outputs e efeitos colaterais observáveis.
- **Sem features novas** — só limpeza, extração e performance segura.

## Saída obrigatória (formato fixo)

Responder **sempre** nesta ordem:

### 1. Código Refatorado

O código final limpo (mostre o arquivo completo ou as funções modificadas de forma clara).

Use citações com path e linhas quando mostrar trechos já gravados; blocos completos quando o ficheiro for curto ou quando o utilizador pedir ficheiro inteiro.

### 2. Explicação das Mudanças

Uma lista em tópicos curtos explicando o que foi melhorado no diff e por quê.

## Checklist antes de concluir

- [ ] Só código do diff ou impacto directo foi alterado
- [ ] Convenções do projecto respeitadas (rules, kwargs, query/use-case objects quando aplicável)
- [ ] Cada nome novo ou renomeado passa no § Teste do nome (`naming-rails.mdc`): frase do que faz/devolve ↔ nome
- [ ] Nenhum método extraído com nome mais vago que o código que esconde
- [ ] Guard clauses onde reduzem aninhamento
- [ ] Sem N+1 novo (`includes`/`preload`/`eager_load` quando necessário)
- [ ] Comportamento preservado (sem alterar contratos públicos sem necessidade do diff original)
