[English](README.md) · **Português**

# Terminais

A única dependência é o tmux, então o `work`, o painel e os atalhos funcionam
igual em qualquer terminal. O que muda de um terminal para outro são os extras:
as cores, a fonte e os atalhos próprios dele.

A instalação pergunta qual terminal você usa (kitty, Warp ou outro), confere se
ele está instalado e configura os extras que ele aceita. **Ela não instala
terminal:** se o escolhido faltar, diz onde baixar, e você roda a instalação de
novo depois. Para responder sem a pergunta, use `--terminal kitty`,
`--terminal warp` ou `--terminal other`; a escolha fica salva em
`~/.config/workdeck/terminal`.

No kitty e no Warp, uma segunda pergunta oferece o **visual** do workdeck: o
tema e a fonte JetBrains Mono, baixada das releases oficiais, sem sudo. A
resposta padrão é não (Enter recusa). `--visual` aceita sem perguntar e
`--no-visual` recusa; a resposta fica em `~/.config/workdeck/visual`.

## kitty

Com o kitty escolhido e instalado, a instalação acrescenta um bloco ao seu
`~/.config/kitty/kitty.conf` com os atalhos:

- **Option como Alt** no Mac, para os atalhos diretos com Alt.
- **cmd** no Mac: `cmd+h` abre o menu, `cmd+enter` divide a tela, `cmd+1…9`
  vai para a janela, `cmd+d` / `cmd+shift+d` divide ao lado / embaixo,
  `cmd+shift+enter` dá zoom, `cmd+shift+w` fecha o painel.

Se você aceitar o visual, o mesmo bloco ganha também:

- **Tema** do workdeck (`--theme`), o mesmo da barra do tmux.
- **Fonte** JetBrains Mono, com espaçamento de linha um pouco maior.
- **Margem** de 8 pontos entre o texto e a borda da janela. Com o tema, o fundo
  do kitty tem a cor do fundo do tmux, e a margem se mistura a ele.

Sem o visual, o kitty fica com o tema e a fonte dele. Se uma versão antiga do
workdeck já tinha posto o tema e a fonte no seu `kitty.conf`, a atualização
mantém os dois e salva isso como a sua escolha.

A instalação encontra o kitty em `/Applications` ou `~/Applications` (Mac), em
`~/.local/kitty.app` (Linux) ou no `PATH`. O que você escreveu fora dos
marcadores `# >>> workdeck >>>` não muda, e o desinstalador tira só o bloco. O
kitty continua instalado.

## Warp

Com o [Warp](https://www.warp.dev/) escolhido, a instalação confere se ele está
instalado. O `work` abre e o tmux faz o resto: os atalhos `Alt` e a barra valem
normalmente. O painel reconhece o Warp pela variável `WARP_CLIENT_VERSION`.

Se você aceitar o visual, a instalação copia o tema para a pasta de temas do
Warp e baixa a fonte JetBrains Mono:

| Sistema | Onde o tema fica |
|---|---|
| macOS | `~/.warp/themes/workdeck-<tema>.yaml` |
| Linux | `~/.local/share/warp-terminal/themes/workdeck-<tema>.yaml` |

O Warp não troca de tema nem de fonte por arquivo, então o último passo é seu:

- **Tema.** Em **Settings › Appearance › Themes**, escolha `workdeck <tema>`.
  Também dá para buscar "Open theme picker" na Command Palette. O Warp pode levar
  alguns minutos para notar a pasta nova; reabrir o app resolve.
- **Fonte.** Em **Settings › Appearance › Text › Font type**, escolha JetBrains
  Mono.
- **Option como Alt (só no Mac).** Os atalhos `Alt` do tmux (`Alt+1…9`,
  `Alt+setas`) só funcionam se a Option for tratada como Alt. Em
  **Settings › Features**, ligue **Left Option key is Meta**. A instalação não liga
  isso por você, porque o Warp guarda essa opção no `settings.toml` dele e o
  reescreve.

O que **não** vem para o Warp: os atalhos `cmd`. O `keybindings.yaml` do Warp só
liga teclas a ações do próprio Warp e não tem uma ação de enviar texto, que é o
que traduz `cmd+1…9` e companhia para o prefixo do tmux.

O `work uninstall` remove o tema copiado, a não ser que você o tenha editado.

Se você abrir de outro terminal uma sessão do tmux iniciada no Warp, a variável
`WARP_CLIENT_VERSION` continua no ambiente do tmux e o painel mostra o aviso do
Warp.

## Qualquer outro terminal

iTerm2, Ghostty, WezTerm, o terminal que vem no sistema ou uma conexão por SSH:
o `work` abre do mesmo jeito, porque os atalhos são do tmux. No Mac, ligue a
Option como Meta nas configurações do terminal para usar os atalhos Alt. O tema
e a fonte, se você quiser, são configurados no próprio terminal.
