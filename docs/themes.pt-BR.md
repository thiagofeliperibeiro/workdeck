[English](themes.md) · **Português**

# Temas

Cada tema pinta o tmux e, se você aceitar o visual na instalação, o kitty ou o
Warp também.

| Tema | Fundo | Jeito |
|---|---|---|
| `catppuccin-mocha` | `#1e1e2e` | Pastel por construção. O padrão. |
| `nord` | `#2e3440` | Frio e dessaturado. Verde e vermelho ficam próximos em luminosidade, o que pesa ao ler diff. |
| `min-dark` | `#1f1f1f` | Neutro, derivado do Min Dark do VS Code, com o contraste do texto baixado para ~9,6:1. |

## Trocar

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh | bash -s -- --theme nord
```

A escolha fica salva como `THEME` em `~/.config/workdeck/settings.conf`, e o `work update` mantém o
tema escolhido.

## Criar um tema

Crie três arquivos em `themes/`:

- `<nome>.conf` com as cores do kitty (`background`, `foreground`,
  `color0`–`color15`);
- `<nome>.tmux` com as do tmux (barra, janela ativa, bordas de painel);
- `<nome>.warp.yaml` com as do Warp (`accent`, `cursor`, `background`,
  `foreground` e `terminal_colors`). O `name` é `workdeck <nome>`, que é como o
  tema aparece no seletor do Warp.

O instalador cola cada um no lugar certo. Como os temas ficam no código, um
tema próprio pede um fork (veja [Customizando](customizing.pt-BR.md)).

Vale olhar o contraste antes de fechar um tema. Em fundo escuro, texto acima de
11:1 cansa em sessão longa, e nada abaixo de 4,5:1 deve carregar informação.
Vermelho e verde precisam se separar também em luminosidade, não só em matiz,
senão o diff fica difícil de ler em tela não-retina.
