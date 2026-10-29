# Mudanças

O `work update` mostra o trecho da versão nova antes de perguntar se quer
atualizar. Cada versão é uma tag `vX.Y.Z`.

## v1.1.0

- As suas escolhas ficam num arquivo só, `~/.config/workdeck/settings.conf`, uma `CHAVE="valor"` por linha: terminal, tema, visual, agente, integrações, zsh e o aviso de versão nova. Antes cada uma tinha o seu arquivo. O `work update` junta os arquivos antigos no novo sozinho e não perde nenhuma escolha. Pode editar à mão; a instalação só preenche o que faltar e só reescreve uma chave quando você pede com uma flag, como `--theme`.
- Novo `ACTIVE_PANE="line"` no `settings.conf`: um traço fino na cor de destaque do tema sobre o painel ativo, para saber onde está o foco quando há dois painéis lado a lado (o tmux pinta só metade da borda). Vem desligado; `Ctrl+b r` aplica, sem reiniciar a sessão. O traço ocupa uma linha no topo da janela.

## v1.0.1

- O `work update` não trava mais quando uma versão é republicada com o mesmo nome: a busca de versões passa a aceitar a tag nova no lugar da antiga.

## v1.0.0

O workdeck é um framework para trabalhar com agentes de IA no terminal,
construído sobre o tmux. Esta é a primeira versão numerada do zero; quem já
usava o workdeck recebe esta atualização normalmente e não perde nenhuma
escolha.

- `work` abre uma sessão do tmux com uma janela por projeto e o painel do workdeck. A sessão sobrevive a fechar o terminal, e depois de reiniciar a máquina o `work` abre os projetos de novo.
- Os comandos do dia a dia: `work`, `work add`, `work review`, `work update`, `work kill` e `work uninstall`. O menu (Ctrl+b h) lista os projetos, as ações e os atalhos.
- `work review` pede ao seu agente de IA uma revisão da mudança antes do commit, num painel separado da conversa que escreveu o código, com uma bolinha por achado: vermelha para bug a corrigir antes do commit, laranja para atenção que pode ficar para depois e verde para o que está certo, e no fim um veredito.
- O painel mostra a branch e as mudanças de cada projeto. Qualquer executável em `~/.config/workdeck/panels/` vira um bloco do painel, e `chmod -x` desliga um bloco, inclusive os que vêm prontos.
- Funciona em qualquer terminal: a única dependência é o tmux. A instalação pergunta qual terminal você usa e oferece os extras dele: no kitty, os atalhos `cmd` e, se você quiser, o tema e a fonte JetBrains Mono; no Warp, o tema copiado para a pasta dele e onde escolher tema, fonte e a Option como Meta. O workdeck não instala terminal.
- Três temas (`catppuccin-mocha`, `nord` e `min-dark`) e o zsh do workdeck opcional, com oh-my-zsh e zinit.
- Integrações opcionais com `--with`: BMAD, Spec Kit e ai-memory.
- Instalação numa linha com `get.sh` e reversível: o que ela escreve nos seus arquivos fica entre marcadores, e o `work uninstall` desfaz tudo.
- README e guias em inglês e em português. O que aparece no terminal é em português.
