[English](shortcuts.md) · **Português**

# Atalhos

## kitty: os atalhos do workdeck

Se você aceitou o kitty na instalação, o workdeck cria atalhos próprios nele. A letra é a mesma em todo lugar: <kbd>⌘</kbd> no Mac,
<kbd>Ctrl</kbd>+<kbd>Shift</kbd> no kitty do Linux.

| Para | macOS | Linux |
|---|---|---|
| **Abrir o menu** (o resto está nele) | <kbd>⌘</kbd>+<kbd>H</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>H</kbd> |
| Adicionar um projeto | <kbd>⌘</kbd>+<kbd>P</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> |
| Ir para o projeto 1…9 | <kbd>⌘</kbd>+<kbd>1</kbd>…<kbd>9</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>1</kbd>…<kbd>9</kbd> |
| Projeto anterior / próximo | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Abrir o agente num painel novo | <kbd>⌘</kbd>+<kbd>A</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>A</kbd> |
| Abrir um terminal num painel novo (2, 3 e depois 4 painéis em grade) | <kbd>⌘</kbd>+<kbd>T</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>T</kbd> |
| Zoom no painel, e de novo para voltar | <kbd>⌘</kbd>+<kbd>Z</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Z</kbd> |
| Fechar o painel | <kbd>⌘</kbd>+<kbd>W</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>W</kbd> |

As letras foram escolhidas para lembrar: **H**elp, **P**rojeto, **A**gente,
**T**erminal, **Z**oom, **R**eview, e <kbd>W</kbd> fecha, como em qualquer app
do Mac. Dividir de um jeito específico, renomear, sair deixando rodando,
atualizar e o aviso do agente ficam no menu.

## Qualquer outro terminal

O Warp, o iTerm2, o terminal do sistema e os outros ficam com os atalhos do
tmux, que funcionam em qualquer terminal:

| Para | Teclas |
|---|---|
| **Abrir o menu** | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Projeto anterior / próximo | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Painel anterior / próximo | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Ir para a janela N | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>1</kbd>…<kbd>9</kbd> |
| Abrir um terminal em grade | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>g</kbd> (ou <kbd>Enter</kbd>) |
| Dividir ao lado / embaixo | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>v</kbd> / <kbd>-</kbd> |
| Zoom no painel | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>z</kbd> |
| Fechar o painel | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd> |
| Sair e deixar a sessão rodando | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>d</kbd> |
| Mandar <kbd>Ctrl</kbd>+<kbd>b</kbd> para o programa do painel | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Ctrl</kbd>+<kbd>b</kbd> |

<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> quer dizer: aperte
<kbd>Ctrl</kbd>+<kbd>b</kbd>, solte e aperte a tecla. Eles também funcionam no
kitty, para quem já usa tmux. O mouse também funciona: clique numa
janela na barra de baixo, ou num painel, arraste a borda para redimensionar e
arraste uma aba para reordenar os projetos; a ordem fica salva para o próximo
`work`.

Programas do painel que também usam <kbd>Ctrl</kbd>+<kbd>b</kbd> recebem a
tecla quando você aperta duas vezes. No Claude Code, <kbd>Ctrl</kbd>+<kbd>b</kbd>
<kbd>Ctrl</kbd>+<kbd>b</kbd> manda um comando em execução para o segundo plano.

No menu, cada projeto usa o número da janela como tecla. <kbd>q</kbd> ou
<kbd>Esc</kbd> fecha.

### Com Alt, em qualquer terminal

<kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> vai para a janela e
<kbd>Alt</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> troca de painel. No Mac, eles
precisam da Option como Meta: o kitty já vem assim; para os outros, veja
[terminals/README.pt-BR.md](../terminals/README.pt-BR.md#qualquer-outro-terminal).

## Saber qual painel está ativo

Com dois painéis lado a lado, o tmux pinta só metade da borda compartilhada na
cor do painel ativo, e fica fácil perder de vista onde está o foco. Para um
traço fino na cor de destaque do tema sobre o painel ativo, acrescente isto ao
`~/.config/workdeck/settings.conf` e aperte <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd>:

```
ACTIVE_PANE="line"
```

O traço ocupa uma linha no topo da janela. `"none"`, o padrão, mantém as
bordas do tema.

## Criar ou trocar um atalho

Ponha o `bind` no seu `~/.tmux.conf`, **depois** do bloco do workdeck: o que
estiver antes é desligado junto com os atalhos padrão do tmux, e o bloco é
reescrito a cada atualização.

```tmux
bind -n M-S-G new-window -c "#{pane_current_path}" lazygit
```

Depois, <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> recarrega a configuração.
