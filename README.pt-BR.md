<div align="center">

# workdeck

**Um framework para trabalhar com agentes de IA no terminal, construído sobre o tmux.**

Uma janela por projeto, o agente ao lado do código com os arquivos alterados à
vista, um painel com o estado de tudo — numa sessão que não se perde.

[English](README.md) · **Português**

[Como funciona](#como-funciona) ·
[Instalação](#instalação) ·
[Primeiros passos](#primeiros-passos) ·
[Recursos](#recursos) ·
[Documentação](#documentação)

[![CI](https://github.com/thiagofeliperibeiro/workdeck/actions/workflows/ci.yml/badge.svg)](https://github.com/thiagofeliperibeiro/workdeck/actions/workflows/ci.yml)
![macOS](https://img.shields.io/badge/macOS-suportado-555?logo=apple)
![Linux](https://img.shields.io/badge/Linux-suportado-555?logo=linux&logoColor=white)
![Licença MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-555)

</div>

---

> O workdeck fala português ou inglês: o instalador pergunta qual na primeira
> vez. As integrações, o desinstalador e o `get.sh` continuam em português e
> passam a seguir o idioma na próxima versão.

## Por que o workdeck

Trabalhar com um agente de IA no terminal costuma virar uma pilha de abas: o
agente num lugar, o git em outro, o servidor rodando em algum canto, e cada
projeto com o seu próprio caos. O workdeck organiza isso num só lugar.

- **Uma janela por projeto.** `work` abre todos de uma vez; <kbd>Shift</kbd>+<kbd>←</kbd> <kbd>→</kbd> troca entre eles.
- **O agente ao lado do código.** Funciona com qualquer agente de CLI — Claude Code, Codex, Copilot CLI, Aider, Gemini. Nenhum vem embutido.
- **Um painel com o que importa.** Branch e mudanças de cada projeto, e o que mais você quiser ver.
- **Veja o que mudou.** No Claude Code, o painel de diff abre ao lado da conversa, e você revisa cada mudança antes do commit com os comandos de review do próprio agente.
- **Saiba quando um agente termina.** Enquanto você trabalha numa janela, uma ✦ na barra marca a janela cujo agente terminou ou está esperando você, com notificação do sistema opcional.
- **Veja os limites do seu plano.** A barra mostra quanto dos limites de 5 horas e semanal do Claude Code ou do Codex você já usou.
- **Nada se perde.** Fechou o terminal ou caiu a conexão? `work` e tudo está onde estava, agente incluso.
- **Qualquer terminal, melhor no kitty.** O workdeck roda sobre o tmux, a única dependência, então o `work` funciona igual no Warp, no iTerm2 ou no terminal que vem no sistema. No kitty, ele ainda cria atalhos de uma letra.
- **Pronto em um comando, reversível em outro.** Instala o tmux, se faltar, oferece os atalhos e o visual no kitty; `work uninstall` desfaz tudo.

## Como funciona

Cada projeto é uma janela. Dentro dela, o seu agente roda com os arquivos
alterados ao lado da conversa (o painel de diff do Claude Code). Antes do
commit, revise a mudança ali, com os comandos de review do próprio agente, como
o `/code-review`:

```
┌─ seu terminal ───────────────────────────────────────────────┐
│                               │                              │
│  seu agente de IA             │  arquivos alterados          │
│  (claude, codex…)             │  src/api.ts           +12 -3 │
│  > /code-review               │  src/auth.ts           +4    │
│                               │                              │
├──────────────────────────────────────────────────────────────┤
│ 1 painel  2 api  3 web  4 mobile                Shift+← →    │
└──────────────────────────────────────────────────────────────┘
```

A barra de baixo lista os projetos na primeira linha, e o uso do agente, a
branch e o relógio na segunda. A janela 1 é o painel, com a branch e as
mudanças de todos eles.

O ciclo de trabalho:

```
work add ~/api  →  janela do projeto  →  agente ao lado  →  painel de diff  →  commit
   uma vez           sempre aberta        escreve o código    você revisa       você
```

## Instalação

```bash
curl -fsSL https://workdeck.dev/install | bash
```

Funciona no macOS e no Linux (inclusive WSL). O instalador detecta o sistema,
instala o tmux, se faltar, oferece os atalhos e o visual do workdeck no
[kitty](https://sw.kovidgoyal.net/kitty/) (e baixar o kitty, se você quiser) e
configura tudo. Nada é sobrescrito: o que ele escreve nos
seus arquivos fica entre marcadores `# >>> workdeck >>>`.

<details>
<summary>Ler o script antes de rodar, ou passar opções</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh -o get.sh
less get.sh && bash get.sh
```

As opções vão no fim: `curl -fsSL … | bash -s -- --theme nord`. A lista
completa está em [docs/installation.pt-BR.md](docs/installation.pt-BR.md).

</details>

## Primeiros passos

**1. Abra uma janela nova do terminal** (ou feche e abra o terminal, se a
instalação rodou nele) para carregar o comando `work` e o shell novo.

**2. Abra o workdeck:**

```bash
work
```

Na primeira vez, ele abre só o painel, mostrando o que falta configurar.

**3. Adicione os seus projetos:**

```bash
work add ~/code/api        # Tab completa o caminho
work add                   # sem caminho, usa a pasta atual
```

Cada projeto vira uma janela. Abra o seu agente numa delas (`claude`, `codex`…)
e trabalhe como sempre.

**4. Antes do commit, revise a mudança** no painel de diff ao lado do agente, ou
peça ao próprio agente, como o `/code-review` no Claude Code.

> **Ficou perdido?** <kbd>Ctrl</kbd>+<kbd>b</kbd> e depois <kbd>h</kbd> abre o
> menu com os projetos, as ações e os atalhos. <kbd>q</kbd> ou <kbd>Esc</kbd> fecha.

## Recursos

### Comandos

| Comando | O que faz |
|---|---|
| `work` | Abre a sessão, ou volta para ela |
| `work add [caminho]` | Acrescenta um projeto como janela |
| `work update` | Mostra o que mudou na versão nova e atualiza |
| `work kill` | Fecha a sessão inteira |
| `work uninstall` | Desinstala tudo o que o workdeck instalou |

### Atalhos

Use o [kitty](https://sw.kovidgoyal.net/kitty/) para a melhor experiência: o
workdeck cria atalhos próprios nele, uma letra cada: <kbd>⌘</kbd> no Mac, <kbd>Ctrl</kbd>+<kbd>Shift</kbd> no kitty do
Linux.

| Para | macOS | Linux |
|---|---|---|
| **Abrir o menu** | <kbd>⌘</kbd>+<kbd>H</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>H</kbd> |
| Adicionar um projeto | <kbd>⌘</kbd>+<kbd>P</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> |
| Ir para o projeto 1…9 | <kbd>⌘</kbd>+<kbd>1</kbd>…<kbd>9</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>1</kbd>…<kbd>9</kbd> |
| Projeto anterior / próximo | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Abrir o agente / um terminal | <kbd>⌘</kbd>+<kbd>A</kbd> / <kbd>T</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>A</kbd> / <kbd>T</kbd> |
| Zoom / fechar o painel | <kbd>⌘</kbd>+<kbd>Z</kbd> / <kbd>W</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Z</kbd> / <kbd>W</kbd> |

No Warp, no iTerm2, no terminal do sistema ou em qualquer outro, valem os atalhos do tmux:
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> abre o menu (aperte
<kbd>Ctrl</kbd>+<kbd>b</kbd>, solte e aperte <kbd>h</kbd>) e
<kbd>Shift</kbd>+setas trocam de projeto e de painel. Todos os atalhos estão em
[docs/shortcuts.pt-BR.md](docs/shortcuts.pt-BR.md).

### O painel de diff

No Claude Code, o agente abre com o painel de diff ao lado da conversa: os
arquivos alterados no projeto e o que mudou em cada um. O workdeck liga o
renderizador fullscreen do Claude, que o painel precisa, e inicia o Claude com
`/diff`, tanto pelo <kbd>⌘</kbd>+<kbd>A</kbd> no kitty quanto quando você digita
`claude` num painel. Para revisar antes do commit, use os comandos do próprio
agente, como o `/code-review`.
[Como funciona →](docs/projects.pt-BR.md#o-painel-de-diff-no-claude-code)

### Painel personalizável

A janela 1 é o painel: a visão geral do seu work em cima e um terminal embaixo.
Ele vem com o estado dos projetos, e você põe ali o que quiser acompanhar:
containers, PRs abertos, o build do CI, as tarefas do dia.

Cada bloco do painel é um programa em `~/.config/workdeck/panels/`. O painel
roda todos em ordem alfabética, mostra o que cada um imprime e repete a cada
60 segundos. Para acrescentar um:

```bash
cat > ~/.config/workdeck/panels/30-docker <<'EOF'
#!/usr/bin/env bash
docker ps --format '{{.Names}}  {{.Status}}'
EOF
chmod +x ~/.config/workdeck/panels/30-docker
```

No próximo ciclo, os seus containers aparecem com o título "Docker". Qualquer
linguagem serve, desde que imprima texto; `chmod -x` desliga um painel,
inclusive os que vêm prontos.
[Passo a passo, regras e ideias →](docs/panels.pt-BR.md)

### Temas

Três temas, aplicados ao tmux e, se você aceitar o visual, ao kitty: `catppuccin-mocha` (padrão),
`nord` e `min-dark`. Para trocar, rode a instalação com `--theme nord`; a
escolha fica salva para as próximas atualizações.
[Criar o seu tema →](docs/themes.pt-BR.md)

## Atualizar e desinstalar

```bash
work update          # mostra o que mudou e pergunta antes de atualizar
work uninstall       # mostra o que vai sair e pergunta antes de apagar
```

O workdeck confere sozinho se há versão nova, no máximo uma vez por dia e sem
nunca esperar pela internet. Só contam versões publicadas; o que muda em cada
uma está no [CHANGELOG](CHANGELOG.md), em português e inglês. Atualizar mantém
os seus projetos, painéis e escolhas.

O desinstalador só remove o que o workdeck instalou. Um kitty ou um oh-my-zsh
que você já tinha continua lá, e dá para devolver os seus arquivos ao estado
exato de antes da instalação. [Detalhes →](docs/installation.pt-BR.md#desinstalar)

## Documentação

| Guia | Conteúdo |
|---|---|
| [Instalação](docs/installation.pt-BR.md) | Opções do instalador, o zsh, onde fica cada arquivo, desinstalar |
| [Projetos](docs/projects.pt-BR.md) | Adicionar, tirar e reordenar; o `projects.conf` |
| [Atalhos](docs/shortcuts.pt-BR.md) | Todos os atalhos, os extras do terminal e como criar os seus |
| [Painéis](docs/panels.pt-BR.md) | Os painéis que vêm prontos e como fazer os seus |
| [Temas](docs/themes.pt-BR.md) | Os temas e como criar um |
| [Agente e integrações](docs/integrations.pt-BR.md) | O agente de IA, BMAD, Spec Kit e ai-memory |
| [Customizando](docs/customizing.pt-BR.md) | O que dá para mudar e onde |
| [Contribuindo](CONTRIBUTING.md) | Estrutura do código, testes e como enviar mudanças (em inglês) |
| [Segurança](SECURITY.md) | O que o instalador faz e como relatar uma falha (em inglês) |

## Filosofia

O workdeck é para trabalhar com **agentes de IA de linha de comando** (Claude
Code, Codex, Gemini CLI, Aider…) no terminal. Ele organiza tudo em volta do
agente e não substitui nenhum. Cada recurso serve a um fluxo:

- **Projeto:** uma janela por projeto, que volta como estava depois de fechar o
  terminal.
- **Agente:** o agente em cada projeto, a ✦ e o aviso quando ele termina, os
  limites de uso na barra e o painel com o estado de tudo.
- **Review:** o painel de diff do Claude Code ao lado do agente, e os comandos
  de review do próprio agente antes do commit.

Ele não é extensão de editor ou IDE, não é um terminal e não é um agente de IA.
O tmux é o motor por baixo, e o kitty dá a melhor experiência.

O workdeck é um ponto de partida. Ele traz a estrutura — sessão, janelas,
painel, painel de diff — e deixa o resto com você: os seus projetos, os seus painéis, o
seu agente. Tudo fica em arquivos de texto simples, e tudo o que ele escreve
pode ser desfeito.

Use, copie, faça um fork e mude o que precisar.

## Licença

[MIT](LICENSE)
