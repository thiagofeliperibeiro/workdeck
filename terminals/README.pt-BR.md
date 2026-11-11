[English](README.md) · **Português**

# Terminais

A única dependência é o tmux, então o `work`, o painel e os atalhos do
tmux funcionam igual em qualquer terminal. Para a melhor experiência, use o
[kitty](https://sw.kovidgoyal.net/kitty/): é o terminal em que o workdeck cria
atalhos próprios e, se você quiser, coloca o tema e a fonte dele.

## kitty, o recomendado

A instalação pergunta se você quer os atalhos do workdeck no kitty. Se o kitty
ainda não estiver instalado, ela oferece baixar pelo instalador oficial do
kitty, que não pede senha. Você também pode recusar e instalar depois: a
configuração é gravada mesmo assim, e o kitty já abre pronto. Para responder sem
a pergunta, use `--terminal kitty` ou `--terminal other`; a escolha fica salva
em `~/.config/workdeck/settings.conf` (`TERMINAL`).

A instalação acrescenta um bloco ao seu `~/.config/kitty/kitty.conf` com:

- **O kitty abre direto no `work`.** A primeira janela do kitty já entra na
  sessão do workdeck, e o kitty funciona como o app do workdeck; janelas novas
  (`⌘N`) abrem um shell comum, e sair com <kbd>Ctrl</kbd>+<kbd>b</kbd>
  <kbd>d</kbd> deixa um shell na janela. `KITTY_OPENS_WORK="no"` no
  `settings.conf` desliga na próxima vez que você rodar a instalação, e um
  `startup_session` seu no `kitty.conf` sempre vale mais.
- **Uma tecla global para o workdeck.** A janela de acesso rápido do kitty
  abre no `work`, então uma tecla traz o workdeck por cima de qualquer app. No
  Mac, escolha a tecla uma vez em Ajustes do Sistema › Teclado › Atalhos de
  Teclado › Serviços › Geral › "Quick access to kitty"; no Linux, ligue uma
  tecla ao comando `kitten quick-access-terminal` nas configurações de teclado
  do sistema. A configuração fica num bloco marcado em
  `~/.config/kitty/quick-access-terminal.conf`.
- **Aviso de agente pelo kitty.** Com `NOTIFY_AGENTS="yes"`, o aviso de que um
  agente terminou sai pelo kitty, e clicar nele traz o kitty para a frente.
- **Os atalhos do workdeck**, <kbd>⌘</kbd> no Mac e
  <kbd>Ctrl</kbd>+<kbd>Shift</kbd> no Linux: H menu, P adicionar projeto, 1…9
  ir para o projeto, A agente, T terminal, Z zoom, W fechar. A tabela
  completa está em [docs/shortcuts.pt-BR.md](../docs/shortcuts.pt-BR.md).
- **Option como Alt** no Mac, para os atalhos diretos com Alt.
- **Shift+Enter** no formato estendido, para que agentes como o Claude Code
  pulem a linha em vez de enviar a mensagem. Só vale enquanto o tmux roda na
  janela.

Uma segunda pergunta oferece o **visual** do workdeck no kitty: o tema
(`--theme`, o mesmo da barra do tmux), a fonte JetBrains Mono e uma margem de 8
pontos. `--visual` aceita sem perguntar e `--no-visual` recusa; a resposta fica
salva como `VISUAL`.

O `work uninstall` tira só o bloco: o que você escreveu fora dos marcadores
`# >>> workdeck >>>` fica. Depois ele pergunta se o kitty sai também; a resposta
padrão é não.

## Qualquer outro terminal

Warp, iTerm2, o Terminal do macOS, Ghostty, WezTerm ou uma conexão por SSH: o
`work` abre do mesmo jeito, com os atalhos do tmux.

| Para | Teclas |
|---|---|
| Abrir o menu | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Projeto anterior / próximo | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Painel anterior / próximo | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Ir para a janela N | <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> |

No Mac, os atalhos Alt precisam da Option como Meta nas configurações do
terminal:

- **iTerm2:** Settings › Profiles › Keys › Left Option key › Esc+.
- **Terminal:** Ajustes › Perfis › Teclado › Usar Option como tecla Meta.
- **Warp:** Settings › Features › Left Option key is Meta.

O tema e a fonte são configurados no próprio terminal. Para o Warp, os temas do
workdeck estão em `themes/<tema>.warp.yaml`: copie um para `~/.warp/themes/` e
escolha em Settings › Appearance › Themes.

Versões anteriores copiavam o tema do Warp e gravavam um profile do iTerm2; o
`work update` remove o profile do iTerm2, e o `work uninstall` remove os dois, a
não ser que você os tenha editado.
