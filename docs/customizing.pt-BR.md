[English](customizing.md) · **Português**

# Customizando

Quase tudo no workdeck é para ser trocado.

| Para mudar | Onde | Depois |
|---|---|---|
| Os projetos e a ordem das janelas | `~/.config/workdeck/projects.conf` | `work kill` e `work` |
| Um atalho do teclado | o seu `~/.tmux.conf`, depois do bloco do workdeck | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> |
| Os atalhos `cmd` e o visual do kitty | o seu `kitty.conf`, fora do bloco do workdeck | reabra o kitty |
| As cores | a instalação com `--theme <nome>` | — |
| O destaque do painel ativo | `ACTIVE_PANE="line"` em `~/.config/workdeck/settings.conf` | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> |
| O agente de IA, o terminal e as outras escolhas salvas | `~/.config/workdeck/settings.conf` | rode a instalação de novo |
| O que aparece no painel | `~/.config/workdeck/panels/` | nada, ele relê sozinho |
| O tema do oh-my-zsh | `export WORKDECK_ZSH_THEME=<tema>` no `.zshrc` | reabra o terminal |
| O nome da sessão | `export WORKDECK_SESSION=outro` | — |
| Algo que não existe aqui | um fork, com o seu comando no `bin/work` | `./install.sh` no fork |

O instalador só gerencia o que está entre os marcadores `# >>> workdeck >>>`;
o resto dos seus arquivos continua seu. O que você puser fora desses blocos
sobrevive a atualizações.

## O arquivo de configurações

O `~/.config/workdeck/settings.conf` guarda as escolhas que a instalação lembra,
uma `CHAVE="valor"` por linha. Linhas que começam com `#` são comentários. Edite
à mão; a instalação preenche o que faltar e só reescreve uma chave quando você pede com
uma flag, como `--theme` ou `--terminal`.

| Chave | Valores | O que faz |
|---|---|---|
| `LANGUAGE` | `en`, `pt-BR` | O idioma das mensagens; sem ele, o idioma do sistema (`LANG`). Mude com `./install.sh --lang`, que também atualiza as mensagens do tmux e o nome da janela do painel |
| `TERMINAL` | `kitty`, `other` | `kitty` ganha os atalhos do workdeck e, com `VISUAL`, o visual |
| `VISUAL` | `yes`, `no` | O tema e a fonte do workdeck no kitty |
| `PANEL_CLOCK` | `yes`, `no` (padrão) | O painel com o relógio tclock no alto ([Painéis](panels.pt-BR.md)) |
| `KITTY_OPENS_WORK` | `yes` (padrão), `no` | O kitty abre direto no `work`; vale ao rodar a instalação |
| `THEME` | o nome de um tema | As cores do tmux |
| `AGENT_CMD` | um comando | O agente que o <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>A</kbd> abre num painel novo |
| `INTEGRATIONS` | `none` ou uma lista | As integrações opcionais |
| `ZSH` | `yes`, `no` | O zsh do workdeck |
| `NOTIFY` | `0` | `0` desliga o aviso de versão nova (`work update --off`) |
| `ACTIVE_PANE` | `none` (padrão), `line` | Um traço fino sobre o painel ativo, na cor de destaque do tema |
| `NOTIFY_AGENTS` | `yes`, `no` (padrão) | Uma notificação do sistema quando um agente termina numa janela que você não está olhando ([Projetos](projects.pt-BR.md)) |
| `PROJECT_LAYOUT` | `none` (padrão), `agent-shell` | Abre a janela de cada projeto com um painel só, para o agente; `agent-shell` acrescenta um shell ao lado ([Projetos](projects.pt-BR.md)) |

Só valem linhas exatamente no formato `CHAVE="valor"`: `CHAVE=valor`,
`CHAVE = "valor"` e linhas comentadas são ignoradas, e vale a primeira linha de
cada chave. As versões antigas guardavam cada escolha num arquivo próprio; o
`work update` junta todos neste.

## Mantendo a sua versão

Só o `work` vai para o `PATH`. Os outros scripts de `bin/` são peças internas,
chamadas de dentro da instalação em `~/.local/share/workdeck`.

Para ir além da configuração, faça um fork, mude o que quiser e rode o
`./install.sh` de dentro dele. O instalador copia o seu fork para
`~/.local/share/workdeck` e o `work update` passa a seguir as versões dele.
