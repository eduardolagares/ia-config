#!/usr/bin/env python3
"""Renderiza os blocos mermaid de um documento de tarefa em PNG verificado.

Falha em vez de publicar diagrama torto ou quebrado:
- flowchart fora de `LR` -> erro (no Monday a imagem entra com width fixo, e
  diagrama vertical vira uma tira alta e ilegivel);
- resposta que nao e PNG -> erro.

Altura nao e limitada: sequenceDiagram cresce na vertical por natureza, e imagem
alta no doc do Monday e aceitavel. O script so reporta o tamanho medido.

Uso:
    python3 render_diagramas.py docs/tarefas/2026-08-13-....md /tmp/diagramas
    python3 render_diagramas.py --self-check
"""

import base64
import pathlib
import struct
import subprocess
import sys

# ponytail: kroki.io/mermaid vive fora do ar (o proprio host responde noutros
# renderers). mermaid.ink e o que responde hoje; se cair, trocar a URL aqui.
# bgColor e obrigatorio: sem ele o PNG sai com fundo transparente e o texto
# escuro do diagrama some no modo escuro do Monday.
RENDERER = "https://mermaid.ink/img/{payload}?type=png&bgColor=!white"

FENCE = "```mermaid"


def render_url(source):
    payload = base64.urlsafe_b64encode(source.encode("utf-8")).decode("ascii")
    return RENDERER.format(payload=payload)


def png_size(caminho):
    """(largura, altura) do PNG, ou None se o arquivo nao for PNG."""
    dados = caminho.read_bytes()[:24]
    if not dados.startswith(b"\x89PNG\r\n\x1a\n"):
        return None
    return struct.unpack(">II", dados[16:24])


def extract_blocks(text):
    """[(rotulo, source)] na ordem do documento; rotulo = UC mais recente."""
    blocks = []
    rotulo = ""
    linhas = text.splitlines()
    indice = 0
    while indice < len(linhas):
        linha = linhas[indice]
        if linha.startswith("**UC "):
            rotulo = linha.strip("*").split("—")[0].strip()
        if linha.strip() == FENCE:
            fim = indice + 1
            while fim < len(linhas) and not linhas[fim].startswith("```"):
                fim += 1
            blocks.append((rotulo or f"bloco {len(blocks) + 1}", "\n".join(linhas[indice + 1:fim])))
            indice = fim
        indice += 1
    return blocks


def orientacao_invalida(source):
    """Mensagem de erro quando o flowchart nao e horizontal, senao None."""
    # ponytail: valida so flowchart. sequenceDiagram/stateDiagram nao tem
    # orientacao; se algum dia entrar um `graph TD`, incluir aqui.
    primeira = next((l.strip() for l in source.splitlines() if l.strip()), "")
    if primeira.startswith("flowchart") and not primeira.startswith("flowchart LR"):
        return f"{primeira!r} — use `flowchart LR`"
    return None


def baixar(source, destino):
    """Baixa o PNG e devolve mensagem de erro, ou None quando esta utilizavel."""
    subprocess.run(
        ["curl", "-sS", "--max-time", "20", "-o", str(destino), render_url(source)],
        check=False,
    )
    if not destino.exists():
        return "renderer nao respondeu"
    if png_size(destino) is None:
        return f"resposta nao e PNG ({destino.stat().st_size} bytes)"
    return None


def main(caminho, pasta):
    blocks = extract_blocks(pathlib.Path(caminho).read_text(encoding="utf-8"))
    if not blocks:
        print("nenhum bloco mermaid encontrado", file=sys.stderr)
        return 1

    pasta = pathlib.Path(pasta)
    pasta.mkdir(parents=True, exist_ok=True)
    falhas = []
    for indice, (rotulo, source) in enumerate(blocks, start=1):
        problema = orientacao_invalida(source)
        destino = pasta / f"uc{indice}.png"
        if problema is None:
            problema = baixar(source, destino)
        if problema:
            falhas.append(f"{rotulo}: {problema}")
        else:
            largura, altura = png_size(destino)
            print(f"{rotulo}\t{destino}\t{largura}x{altura}")

    for falha in falhas:
        print(f"ERRO {falha}", file=sys.stderr)
    return 1 if falhas else 0


def self_check():
    doc = (
        "**UC 1 — Faz algo**\n- passo\n"
        "```mermaid\nflowchart LR\n  A[Um] --> B[Dois]\n```\n"
        "**UC 2 — Falha**\n"
        "```mermaid\nflowchart TD\n  A --> B\n```\n"
    )
    blocks = extract_blocks(doc)
    assert [rotulo for rotulo, _ in blocks] == ["UC 1", "UC 2"], blocks
    assert orientacao_invalida(blocks[0][1]) is None
    assert orientacao_invalida(blocks[1][1]) is not None
    url = render_url("flowchart LR\n  A[Um] --> B[Dois]")
    payload = url.split("/img/")[1].split("?")[0]
    assert base64.urlsafe_b64decode(payload).decode().startswith("flowchart LR")
    # sem bgColor o PNG sai transparente e o texto some no modo escuro do Monday
    assert "bgColor=" in url, url
    print("ok")


if __name__ == "__main__":
    if sys.argv[1:2] == ["--self-check"]:
        self_check()
    else:
        sys.exit(main(sys.argv[1], sys.argv[2]))
