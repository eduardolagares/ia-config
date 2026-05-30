---
name: refatorar-codigo
description: >-
  Refatora código Ruby on Rails do diff (branch vs master, alterações locais ou
  paths indicados) para Clean & Short Code, mantendo comportamento e convenções
  do projeto. Use com /refatorar-codigo, "refatorar diff", "refatorar código"
  ou pedidos de limpeza/encurtamento do código alterado.
disable-model-invocation: true
VERSION: "1.0.2"
---

# refatorar-codigo

**Pacote:** `skills/eduardolagares/refatorar-codigo/` — instalada pelo `install/` em `{destino}/skills/eduardolagares/refatorar-codigo/` (Cursor ou `~/.agents`).

## Papel

Atue como um desenvolvedor Ruby on Rails Sênior e especialista em refatoração de código.

Seu objetivo é analisar as alterações feitas no branch atual em relação à branch `master` (o diff fornecido abaixo) e refatorar esse código para torná-lo o mais limpo, performático e curto possível (Clean & Short Code), mantendo estritamente a mesma funcionalidade original e respeitando as convenções do projeto.

## Obter o escopo (ordem fixa)

1. **Paths indicados pelo utilizador** — refatorar só esses ficheiros (e código diretamente impactado).
2. **Alterações locais não comitadas** — `git status` + `git diff` (staged e unstaged).
3. **Diff branch vs `master`** — `git diff master...HEAD` (ou `master..HEAD` se o repo usar merge commits; preferir `...` para comparar com o merge-base).

Se nenhuma fonte tiver alterações → parar e pedir paths ou confirmar branch/base.

Ler `.cursor/rules/`, `AGENTS.md` e convenções observáveis no código antes de refatorar.

## Diretrizes de qualidade (obrigatórias)

1. **Foco no Diff:** Refatore apenas o código que sofreu alterações ou que está diretamente impactado pelas mudanças entre as branches.
2. **Padrões Rails:** Use padrões modernos (Service/Query/Form Objects se o código modificado estiver inflando Models ou Controllers).
3. **Regras de Sandi Metz:** Métodos curtos (idealmente até 5 linhas) e princípio de responsabilidade única.
4. **Idiomas do Ruby:** Use cláusulas de guarda (guard clauses), memoization (`||=`) e métodos nativos de enumerable para reduzir o tamanho do código sem perder legibilidade.
5. **Performance:** Garanta que as novas alterações não introduzam queries N+1 ou alocações de memória desnecessárias.

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
- [ ] Métodos curtos; guard clauses onde reduzem aninhamento
- [ ] Sem N+1 novo (`includes`/`preload`/`eager_load` quando necessário)
- [ ] Comportamento preservado (sem alterar contratos públicos sem necessidade do diff original)
