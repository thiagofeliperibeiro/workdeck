<div align="center">

# workdeck

**Um framework para trabalhar com agentes de IA no terminal, construído sobre o tmux.**

Uma janela por projeto, o agente ao lado, um painel com o estado de tudo
e um code review antes de cada commit — numa sessão que não se perde.

[English](README.md) · **Português**

[Como funciona](#como-funciona) ·
[Instalação](#instalação) ·
[Primeiros passos](#primeiros-passos) ·
[Recursos](#recursos) ·
[Documentação](#documentação)

[![CI](https://github.com/workdeckdev/workdeck/actions/workflows/ci.yml/badge.svg)](https://github.com/workdeckdev/workdeck/actions/workflows/ci.yml)
![macOS](https://img.shields.io/badge/macOS-suportado-555?logo=apple)
![Linux](https://img.shields.io/badge/Linux-suportado-555?logo=linux&logoColor=white)
![Licença MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-555)

</div>

---

## Por que o workdeck

Trabalhar com um agente de IA no terminal costuma virar uma pilha de abas: o
agente num lugar, o git em outro, o servidor rodando em algum canto, e cada
projeto com o seu próprio caos. O workdeck organiza isso num só lugar.

- **Uma janela por projeto.** `work` abre todos de uma vez; <kbd>Shift</kbd>+<kbd>←</kbd> <kbd>→</kbd> troca entre eles.
- **O agente ao lado do código.** Funciona com qualquer agente de CLI — Claude Code, Codex, Copilot CLI, Aider, Gemini. Nenhum vem embutido.
- **Um painel com o que importa.** Branch e mudanças de cada projeto, e o que mais você quiser ver.
- **Review antes do commit.** `work review` pede à sua IA uma revisão da mudança, num painel separado da conversa que escreveu o código.
- **Nada se perde.** Fechou o terminal ou caiu a conexão? `work` e tudo está onde estava, agente incluso.
- **Qualquer terminal.** O workdeck roda sobre o tmux, a única dependência. kitty, Warp, iTerm2 ou o terminal que vem no sistema: o `work` funciona igual em todos.
- **Pronto em um comando, reversível em outro.** Instala o tmux, se faltar, pergunta qual terminal você usa e oferece os extras dele; `work uninstall` desfaz tudo.

## Como funciona

Cada projeto é uma janela. Dentro dela, o agente fica ao lado do seu shell, e o
review abre embaixo do agente quando você pede:

```
┌─ seu terminal ───────────────────────────────────────────────┐
│                               │                              │
│  seu agente de IA             │  seu shell                   │
│  (claude, codex…)             │  git, testes, servidor       │
│                               │                              │
├───────────────────────────────┤                              │
│  work review                  │                              │
│  a IA revisa a mudança        │                              │
│                               │                              │
├──────────────────────────────────────────────────────────────┤
│ 1 painel  2 api  3 web  4 mobile                 Shift+← →   │
└──────────────────────────────────────────────────────────────┘
```

A barra de baixo lista os projetos. A janela 1 é o painel, com a branch e as
mudanças de todos eles.

O ciclo de trabalho:

```
work add ~/api  →  janela do projeto  →  agente ao lado  →  work review  →  commit
   uma vez           sempre aberta        escreve o código    revisa antes      você
```

## Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/workdeckdev/workdeck/main/get.sh | bash
```

Funciona no macOS e no Linux (inclusive WSL). O instalador detecta o sistema,
instala o tmux, se faltar, pergunta qual terminal você usa
([kitty](https://sw.kovidgoyal.net/kitty/), [Warp](https://www.warp.dev/) ou
outro) e configura tudo. O terminal você instala por conta própria; o tema e a
fonte do workdeck nele são opcionais. Nada é sobrescrito: o que ele escreve nos
seus arquivos fica entre marcadores `# >>> workdeck >>>`.

<details>
<summary>Ler o script antes de rodar, ou passar opções</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/workdeckdev/workdeck/main/get.sh -o get.sh
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

**4. Antes do commit, peça uma revisão:**

```bash
work review
```

> **Ficou perdido?** <kbd>Ctrl</kbd>+<kbd>b</kbd> e depois <kbd>h</kbd> abre o
> menu com os projetos, as ações e os atalhos. <kbd>q</kbd> ou <kbd>Esc</kbd> fecha.

## Recursos

### Comandos

| Comando | O que faz |
|---|---|
| `work` | Abre a sessão, ou volta para ela |
| `work add [caminho]` | Acrescenta um projeto como janela |
| `work review [staged\|branch]` | A IA revisa a mudança antes do commit |
| `work update` | Mostra o que mudou na versão nova e atualiza |
| `work kill` | Fecha a sessão inteira |
| `work uninstall` | Desinstala tudo o que o workdeck instalou |

### Atalhos

| Para | Teclas |
|---|---|
| **Abrir o menu** | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Projeto anterior / próximo | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Painel anterior / próximo | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Ir direto para a janela N | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>1</kbd>…<kbd>9</kbd> (no Mac: <kbd>cmd</kbd>+<kbd>1</kbd>…<kbd>9</kbd>) |
| Dividir a tela | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> |
| Zoom no painel | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>z</kbd> |
| Fechar o painel | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd> |
| Sair e deixar tudo rodando | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>d</kbd> |

<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> quer dizer: aperte
<kbd>Ctrl</kbd>+<kbd>b</kbd>, solte, e aperte <kbd>h</kbd>. O mouse também
funciona. Todos os atalhos, inclusive os de uma tecla com Alt, estão em
[docs/shortcuts.pt-BR.md](docs/shortcuts.pt-BR.md).

### Self code review

`work review` manda a mudança para a sua IA revisar antes do commit, e a
resposta vem direta, uma bolinha por achado:

```
🔴 src/api/pedidos.ts:42 — o token vai inteiro para o log
   → logar só o id do usuário
🟠 src/lista.tsx:18 — uma consulta por item dentro do map
   → buscar todos de uma vez antes do map

🔴 corrija os vermelhos antes do commit
```

🔴 é bug, para corrigir antes do commit; 🟠 é atenção, pode ficar para depois;
🟢 está ok. A IA só revisa, não altera nada.

O review usa o agente e os padrões que as instruções do projeto apontam
(`CLAUDE.md`, `AGENTS.md`, skills). Com o Claude Code, cada branch mantém uma
única conversa de review, que lembra o que já foi apontado.
[Como funciona e como personalizar →](docs/review.pt-BR.md)

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

Três temas, aplicados ao tmux e, se você aceitar o visual, ao kitty ou ao Warp: `catppuccin-mocha` (padrão),
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
uma está no [CHANGELOG](CHANGELOG.md). Atualizar mantém os seus projetos,
painéis e escolhas.

O desinstalador só remove o que o workdeck instalou. Um kitty ou um oh-my-zsh
que você já tinha continua lá, e dá para devolver os seus arquivos ao estado
exato de antes da instalação. [Detalhes →](docs/installation.pt-BR.md#desinstalar)

## Documentação

| Guia | Conteúdo |
|---|---|
| [Instalação](docs/installation.pt-BR.md) | Opções do instalador, o zsh, onde fica cada arquivo, desinstalar |
| [Projetos](docs/projects.pt-BR.md) | Adicionar, tirar e reordenar; o `projects.conf` |
| [Atalhos](docs/shortcuts.pt-BR.md) | Todos os atalhos, os extras do terminal e como criar os seus |
| [Review](docs/review.pt-BR.md) | Como o `work review` funciona e como personalizar |
| [Painéis](docs/panels.pt-BR.md) | Os painéis que vêm prontos e como fazer os seus |
| [Temas](docs/themes.pt-BR.md) | Os temas e como criar um |
| [Agente e integrações](docs/integrations.pt-BR.md) | O agente de IA, BMAD, Spec Kit e ai-memory |
| [Customizando](docs/customizing.pt-BR.md) | O que dá para mudar e onde |
| [Contribuindo](CONTRIBUTING.md) | Estrutura do código, testes e como enviar mudanças (em inglês) |
| [Segurança](SECURITY.md) | O que o instalador faz e como relatar uma falha (em inglês) |

## Filosofia

O workdeck é um ponto de partida. Ele traz a estrutura — sessão, janelas,
painel, review — e deixa o resto com você: os seus projetos, os seus painéis, o
seu agente. Tudo fica em arquivos de texto simples, e tudo o que ele escreve
pode ser desfeito.

Use, copie, faça um fork e mude o que precisar.

## Licença

[MIT](LICENSE)
