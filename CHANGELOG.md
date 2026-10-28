# Mudanças

O `work update` mostra o trecho da versão nova antes de perguntar se quer
atualizar. Cada versão é uma tag `vX.Y.Z`.

## v1.4.0

- A instalação pergunta qual terminal você usa (kitty, Warp ou outro), confere se ele está instalado e configura os extras dele. **O workdeck não instala mais o kitty:** se ele faltar, a instalação diz onde baixar. Uma segunda pergunta oferece o tema e a fonte JetBrains Mono no kitty ou no Warp. As flags `--terminal kitty|warp|other` e `--visual` / `--no-visual` respondem sem perguntar, e as respostas ficam em `~/.config/workdeck/`.
- Suporte ao Warp: a instalação copia o tema do workdeck para a pasta de temas dele e mostra onde escolher o tema, a fonte e a Option como Meta em Settings. O painel reconhece o Warp e explica que o `work` funciona com os atalhos `Alt`.
- Quem já usa o kitty com o tema e a fonte do workdeck continua com os dois depois desta atualização, sem precisar responder nada.

## v1.3.0

- README e guias em inglês e em português: `README.md` e `docs/<guia>.md` em inglês, `README.pt-BR.md` e `docs/<guia>.pt-BR.md` em português. O que aparece no terminal continua em português.
- O código passou para o inglês (nomes de arquivos, funções e testes). A sua config é convertida sozinha nesta atualização: `tema` vira `theme`, `integracoes` vira `integrations` e `atualizacao.conf` vira `update.conf`, sem perder nenhuma escolha.
- A instalação numa linha agora é `get.sh`. O endereço antigo, com `instalar.sh`, continua funcionando.
- Se você abriu o `work` antes de atualizar, rode `work kill` e `work` para a sessão usar a versão nova.

## v1.2.0

- O `work review` responde direto, uma bolinha por achado: 🔴 bug para corrigir antes do commit, 🟠 atenção que pode ficar para depois, 🟢 ok. Cada achado vem com arquivo:linha, o problema e a correção em uma frase cada, e no fim um veredito. Explicação longa só se você pedir.

## v1.1.2

- A integração do BMAD segue o padrão oficial do BMAD Method: `npx bmad-method install` no projeto, com Node.js 20.12+ e Python 3.10+, e depois `bmad-help` e `bmad-build` na sua IA.

## v1.1.1

- Sai do desinstalador o código que desfazia o perfil do Terminal.app e do GNOME Terminal, que nenhuma versão atual configura. O workdeck é só terminal e CLI.

## v1.1.0

- Testes automáticos em `tests/` (instalação, tema, painéis, sessão e desinstalação) e lint com shellcheck, rodando no CI do GitHub no Ubuntu e no macOS.
- O código foi reorganizado: o `install.sh` tem uma função por etapa, e os caminhos e funções comuns ficam em `lib/comum.sh`.
- Se o código do workdeck sumir de `~/.local/share/workdeck`, o `work` diz como reinstalar, em vez de abrir uma sessão quebrada.
- Novos `CONTRIBUTING.md` e `SECURITY.md`.

## v1.0.6

- O painel mostra onde pôr o seu próprio bloco, até você criar o primeiro.
- `chmod -x` desliga um painel, inclusive os que vêm prontos, e o `work update` não liga de novo.
- Guia de painéis refeito: passo a passo, regras, ideias e como mudar os que vêm prontos.

## v1.0.5

- README ganha "Como funciona": um desenho da tela (agente, shell, review e a barra de projetos) e o ciclo de trabalho, de `work add` ao commit.

## v1.0.4

- README novo, mais curto e direto: o que é, instalação, primeiros passos e recursos. Os detalhes foram para guias em `docs/` (instalação, projetos, atalhos, review, painéis, temas, integrações e customização).

## v1.0.3

- A instalação não conta mais o kitty que está na pasta de outro usuário do Mac, como o de uma conta apagada, e instala o kitty na sua.

## v1.0.2

- Volta o `work uninstall`, que desinstala tudo o que o workdeck instalou: mostra o que vai sair, pergunta antes e aceita `--dry-run`. O kitty e a fonte que a instalação trouxe saem junto.
- Sem o manifesto da instalação, desinstalar tudo também apaga o código em `~/.local/share/workdeck`.

## v1.0.1

- O zsh do workdeck vem com "sim" como resposta padrão: Enter instala o oh-my-zsh e o zinit com os plugins.
- README revisado: flags que faltavam, atalhos com Alt, o que vai para onde e como apontar o CLAUDE.md para o BMAD, os PRDs e o ai-memory.

## v1.0.0

- `work` abre uma sessão do tmux com uma janela por projeto e o painel do workdeck; a sessão sobrevive a fechar o terminal.
- Cinco comandos: `work`, `work add`, `work review`, `work update` e `work kill`. O menu (Ctrl+b h) lista os projetos e as ações, e mostra os atalhos do dia a dia.
- `work review` pede à IA aberta na janela um self code review antes do commit, usando o agente de review e os PRDs que o CLAUDE.md ou o AGENTS.md apontam.
- Instalação numa linha, com o kitty (tema, fonte JetBrains Mono e atalhos `cmd` no Mac) e o zsh do workdeck: oh-my-zsh com robbyrussell e zinit com três plugins.
- Integrações opcionais (BMAD, Spec Kit, ai-memory), com como instalar e como deixar a IA usando cada uma.
- `work update` avisa quando há versão nova e reaplica a instalação, sem perder o tema e as escolhas feitas.
