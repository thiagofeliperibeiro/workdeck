[English](projects.md) · **Português**

# Projetos

Cada projeto é uma janela da sessão do tmux. O `work` abre todas de uma vez, e
a sessão sobrevive a fechar o terminal ou cair a conexão: `work` de novo e tudo
está onde estava, agente incluso. Reiniciar a máquina fecha a sessão; o `work`
abre as janelas dos projetos de novo, e o agente você abre outra vez.

## Adicionar

```bash
work add ~/code/api        # Tab completa o caminho
work add                   # sem caminho, usa a pasta atual
```

O nome da janela é o nome da pasta. Com a sessão aberta, a janela aparece na
hora; se a pasta já estiver no work, nada muda. Pelo menu
(<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd>), "Adicionar um projeto…" faz o
mesmo.

## Tirar

Feche a janela do projeto: `exit` no último painel, ou
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd>. Ele sai da lista, e o próximo `work`
não abre mais. Fechar só um dos painéis divididos, ou o agente, não tira nada.
Para voltar, `work add` de novo.

## O `projects.conf`

Os projetos ficam em `~/.config/workdeck/projects.conf`, uma linha por janela:

```
nome|caminho|comando opcional
```

```
painel|$HOME|work-panel
api|$HOME/projetos/minha-api
web|$HOME/projetos/meu-front
notas|~/notas
```

- **nome** vira o nome da janela no tmux.
- **caminho** é onde a janela abre; aceita `~` e `$HOME`.
- **comando** é opcional: se existir, a janela roda isso em vez de um shell.

A linha do `work-panel` é a janela do painel. O nome dela segue o seu idioma
(`painel` ou `panel`), e a instalação troca o nome quando você muda com
`--lang`.

A ordem do arquivo é a ordem das janelas, numeradas a partir de 1. Projeto que
não existe no disco é pulado sem erro, então dá para deixar linhas de coisas
que ainda não foram clonadas.

Para reordenar, edite o arquivo, feche a sessão com `work kill` e abra de novo
com `work`. As janelas são criadas na abertura da sessão; sem fechar, a sessão
continua com a lista antiga.

## Saber quando um agente termina

Enquanto você trabalha numa janela, o workdeck acompanha os agentes abertos nas
outras. Quando um agente termina, ou para para perguntar algo, a janela dele
ganha uma ✦ na barra. Uma janela com vários agentes continua com uma
estrela só:

```
 ❯_ work   1 painel   2 api ✦   3 web   4 mobile
```

A estrela some quando você abre a janela, ou quando todos os agentes dela
voltam a trabalhar. A janela que você está olhando nunca é marcada.

No Claude Code e no Codex, o workdeck sabe que o agente está trabalhando
enquanto a linha de status dele, perto do campo de mensagem, mostra "esc to
interrupt"; a mesma frase no meio da conversa não conta. Nos outros agentes,
ele acompanha as mudanças na tela e marca a janela depois de 10 segundos sem
mudança.

Para receber também uma notificação do sistema ("o claude terminou em api"),
escolha "Ligar o aviso quando um agente termina" no menu (<kbd>Ctrl</kbd>+<kbd>b</kbd>
<kbd>h</kbd>). O mesmo item desliga. Ele grava esta linha no
`~/.config/workdeck/settings.conf`, que você também pode escrever à mão:

```
NOTIFY_AGENTS="yes"
```

Ela usa o `osascript` no macOS e o `notify-send` no Linux, quando instalado.

## Limites de uso do agente

O lado direito da barra mostra quanto do seu plano do Claude ou do Codex você
já usou, com uma barra para a janela de 5 horas e outra para a semanal:

```
claude 5h ▰▰▱▱▱ 42% · 7d ▰▱▱▱▱ 12% · main · ctrl+b h menu · 14:05
```

Ela mostra o agente aberto na janela que você está olhando. Numa janela sem
agente, mostra o último que você usou. A barra fica vermelha a partir de 90%, e
uma janela cujo horário de renovação já passou some até o agente informar de
novo.

- **Claude Code** só entrega esses números ao comando de statusline. O
  instalador configura a `statusLine` em `~/.claude/settings.json` (ou em
  `$CLAUDE_CONFIG_DIR`) com `~/.local/share/workdeck/bin/workdeck-statusline`.
  Se você já tinha uma statusline, ela continua aparecendo no Claude, porque o
  workdeck a executa depois de guardar os limites. O `work uninstall` devolve a
  `statusLine` que você tinha. Os números só vêm com assinatura do Claude (Pro
  ou Max) e aparecem depois da primeira resposta da sessão.
- **Codex** grava os limites nos próprios logs de sessão, em
  `~/.codex/sessions` (ou em `$CODEX_HOME`). O workdeck lê esses arquivos e não
  mexe na configuração do Codex. Os números só vêm com um plano do ChatGPT.

O Cursor e os outros agentes não expõem limites que o workdeck consiga ler,
então a barra não mostra nada para eles.

## A janela do projeto

A janela de cada projeto abre com um painel só, um shell comum pronto para você
abrir o agente (como `claude`) nos projetos em que for trabalhar. Nada sobe
sozinho, então abrir muitos projetos não liga vários agentes ao mesmo tempo.
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> divide a janela quando você
precisar de mais painéis, e <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>A</kbd> abre um
painel com o seu agente já rodando.

No Claude Code, o agente abre com o painel de diff ao lado da conversa,
mostrando os arquivos que você alterou: veja [O painel de diff no Claude Code](#o-painel-de-diff-no-claude-code).

### Um shell ao lado do agente

Para abrir a janela de cada projeto com o agente e um shell lado a lado,
acrescente ao `~/.config/workdeck/settings.conf` e rode `work kill` e `work`:

```
PROJECT_LAYOUT="agent-shell"
```

```
┌──────────────┬──────────────┐
│              │              │
│  1 agente    │  2 shell     │
│              │              │
└──────────────┴──────────────┘
```

O shell é para git, testes e o servidor. O comando do `.workdeck/project.conf`
do projeto aparece digitado quando o shell mostra o prompt, sem rodar:

```
SERVER_COMMAND="npm run dev"
```

O arquivo segue as mesmas regras do `settings.conf`: uma `CHAVE="valor"` por
linha, com comentários em linhas próprias. Uma linha em outro formato, como
uma com comentário depois do valor, é ignorada. Caracteres de controle são
removidos antes de digitar, então um valor nunca roda sozinho. Sem esse
arquivo, o painel abre como um shell comum. Como o servidor nunca sobe sozinho,
as portas não entram em conflito quando muitos projetos abrem juntos.

## O painel de diff no Claude Code

O Claude Code tem um painel de diff, aberto com `/diff`, que lista os arquivos
alterados no projeto e mostra o que mudou em cada um. Dá para navegar pelos
arquivos sem sair da conversa. O workdeck abre esse painel para você:

- <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>A</kbd> inicia o Claude como `claude "/diff"`.
- Digitar `claude` sem argumentos num painel do workdeck faz o mesmo, por meio
  de uma função `claude` que o instalador acrescenta ao bloco do workdeck no
  seu `.zshrc` ou `.bashrc`. Fora do workdeck, e com qualquer argumento, como
  `claude --resume`, o `claude` roda como sempre.

O `/diff` roda dentro do Claude e não envia nada ao modelo. Para iniciar o
Claude sem o painel, acrescente `CLAUDE_DIFF_PANEL="no"` ao
`~/.config/workdeck/settings.conf`.

O painel precisa do renderizador fullscreen do Claude Code. O instalador
configura `"tui": "fullscreen"` em `~/.claude/settings.json` (ou em
`$CLAUDE_CONFIG_DIR`) quando você ainda não escolheu um renderizador, o que
equivale a rodar `/tui fullscreen`. Para voltar ao renderizador padrão, rode
`/tui default` no Claude; o workdeck respeita a sua escolha. O `work uninstall`
remove a configuração que ele acrescentou.

## Outra sessão

Para usar outro nome de sessão: `export WORKDECK_SESSION=outro`.
