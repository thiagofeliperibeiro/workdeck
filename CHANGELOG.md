# Mudanças · Changes

O `work update` mostra o trecho da versão nova no seu idioma antes de perguntar
se quer atualizar. Cada versão é uma tag `vX.Y.Z`.

`work update` shows the section of the new version in your language before
asking whether to update. Each version is a `vX.Y.Z` tag.

## v3.2.1

### Português

- No kitty, `Cmd+Enter` (`Ctrl+Shift+Enter` no Linux) abre um terminal num painel novo dentro do workdeck, em grade como o `Cmd+T`, em vez de uma janela do kitty fora da sessão. Depois de atualizar, recarregue a configuração do kitty ou abra o kitty de novo.

### English

- In kitty, `Cmd+Enter` (`Ctrl+Shift+Enter` on Linux) opens a terminal in a new pane inside workdeck, in a grid like `Cmd+T`, instead of a kitty window outside the session. After updating, reload the kitty configuration or open kitty again.

## v3.2.0

### Português

- O painel de diff do Claude Code vem desligado: o `Ctrl+b A` e o `claude` digitado num painel do tmux abrem o Claude sem o `/diff`, e cada janela de projeto fica com um terminal só. Para ligar de novo, acrescente `CLAUDE_DIFF_PANEL="yes"` ao `~/.config/workdeck/settings.conf` e rode `work update`.
- Sem essa configuração, o `work update` tira o renderizador fullscreen que a instalação da v3.0.0 gravou nas configurações do Claude. Um renderizador que você escolheu com `/tui` fica como está.
- Depois de atualizar, abra um terminal novo para o `claude` voltar a abrir sem o painel.

### English

- The Claude Code diff panel is off by default: `Ctrl+b A` and `claude` typed in a tmux pane start Claude without `/diff`, and each project window has a single terminal. To turn it back on, add `CLAUDE_DIFF_PANEL="yes"` to `~/.config/workdeck/settings.conf` and run `work update`.
- Without that setting, `work update` takes out the fullscreen renderer the v3.0.0 install set in the Claude settings. A renderer you chose with `/tui` stays as it is.
- After updating, open a new terminal so `claude` starts without the panel again.

## v3.1.1

### Português

- Os limites de uso do agente ficam no lado direito da segunda linha da barra, junto da branch, do atalho do menu e do relógio.

### English

- The agent usage limits sit on the right of the second line of the bar, next to the branch, the menu key and the clock.

## v3.1.0

### Português

- A barra de baixo tem duas linhas. A primeira traz a sessão e os projetos, com a largura toda, então muitos projetos abertos não espremem mais o resto. A segunda mostra os limites de uso do agente à esquerda e a branch, o atalho do menu e o relógio à direita.

### English

- The bottom bar has two lines. The first holds the session and the projects across the full width, so many open projects no longer squeeze the rest. The second shows the agent usage limits on the left and the branch, menu key and clock on the right.

## v3.0.1

### Português

- O `work update` volta a funcionar quando o workdeck foi instalado a partir de um clone por SSH sem chave carregada, que dava "não consegui falar com o repositório". Ele tenta de novo por HTTPS e passa a usar esse endereço. Se ainda falhar, mostra o erro do git. Se o seu `work update` ainda falha, rode uma vez `git -C ~/.local/share/workdeck remote set-url origin https://github.com/thiagofeliperibeiro/workdeck.git`.

### English

- `work update` works again when workdeck was installed from an SSH clone with no key loaded, which showed "could not reach the workdeck repository". It tries again over HTTPS and keeps that address. If it still fails, it shows git's error. If your `work update` still fails, run `git -C ~/.local/share/workdeck remote set-url origin https://github.com/thiagofeliperibeiro/workdeck.git` once.

## v3.0.0

### Português

- O `work review` saiu, junto com o `Ctrl+b R`, o `⌘R` do kitty, o item do menu e as configurações `REVIEW_COMMAND`, `REVIEW_AGENT_CMD` e `review.md`, que não são mais lidas. Para revisar antes do commit, use os comandos do próprio agente, como o `/code-review` do Claude Code.
- A janela de cada projeto abre com um painel só, para o agente. Para voltar a ter o shell ao lado, acrescente `PROJECT_LAYOUT="agent-shell"` ao `~/.config/workdeck/settings.conf`.
- O Claude Code abre com o painel de diff ao lado da conversa, mostrando os arquivos alterados. Isso vale pelo `Ctrl+b A` e quando você digita `claude` sem argumentos num painel do tmux. A instalação liga o renderizador fullscreen do Claude, que o painel precisa, se você ainda não escolheu outro. Para desligar, use `CLAUDE_DIFF_PANEL="no"`.
- A barra de baixo mostra quanto você já usou dos limites de 5 horas e semanal do Claude Code ou do Codex, com uma barra para cada um. No Claude, a instalação configura a `statusLine`; uma statusline que você já tinha continua aparecendo.
- A margem em volta do tmux e as bordas entre os painéis ficam com a cor do tema, sem mostrar a cor do terminal (como o roxo do terminal do Ubuntu).
- Depois de atualizar, abra um terminal novo para o `claude` abrir com o painel de diff.

### English

- `work review` is gone, along with `Ctrl+b R`, the kitty `⌘R`, the menu item and the `REVIEW_COMMAND`, `REVIEW_AGENT_CMD` and `review.md` settings, which are no longer read. To review before the commit, use the agent's own commands, such as `/code-review` in Claude Code.
- Each project window opens with a single pane, for the agent. To get the shell beside it back, add `PROJECT_LAYOUT="agent-shell"` to `~/.config/workdeck/settings.conf`.
- Claude Code opens with its diff panel beside the conversation, showing the changed files. This applies to `Ctrl+b A` and to typing `claude` with no arguments in a tmux pane. The install turns on the Claude fullscreen renderer the panel needs, unless you already chose another one. To turn it off, use `CLAUDE_DIFF_PANEL="no"`.
- The bottom bar shows how much of the 5-hour and weekly limits of Claude Code or Codex you have used, with a bar for each. For Claude, the install sets `statusLine`; a status line you already had still shows.
- The margin around tmux and the borders between panes take the theme color instead of the terminal's (such as the purple of the Ubuntu terminal).
- After updating, open a new terminal so `claude` opens with the diff panel.

## v2.5.4

### Português

- O workdeck abre bem mais rápido. O kitty entra no `work` sem carregar todo o seu `.zshrc`, e o painel aparece logo, enquanto as abas dos projetos vão surgindo em segundo plano. Rode `work update` e abra o kitty de novo.
- A aba que você arrasta fica acesa com a cor de destaque até você soltar. Os outros projetos ficam parados e a troca acontece ao soltar. Rode `Ctrl+b r` depois de atualizar.
- O painel da IA abre como um shell vazio, sem o `AGENT_CMD` já digitado. Abra o agente nos projetos em que for trabalhar. O comando do servidor continua digitado no shell ao lado.

### English

- workdeck opens much faster. kitty starts `work` without loading your whole `.zshrc`, and the panel shows up right away while the project tabs open in the background. Run `work update` and open kitty again.
- The tab you drag lights up in the accent color until you drop it. The other projects stay in place and the swap happens on drop. Run `Ctrl+b r` after updating.
- The AI pane opens as an empty shell, without the `AGENT_CMD` already typed. Start the agent in the projects you are going to work on. The server command is still typed in the shell beside it.

## v2.5.3

### Português

- Arrastar uma aba para cima do painel, ou arrastar o próprio painel, não faz mais nada parecer quebrado: nada se move e aparece um aviso de que o painel fica sempre em primeiro.
- A instalação pergunta menos. Se o oh-my-zsh já está na sua máquina, ela não oferece o zsh do workdeck. Se você já tem a fonte JetBrains Mono, a pergunta do visual fala só do tema.

### English

- Dragging a tab onto the panel, or dragging the panel itself, no longer looks broken: nothing moves and a message says the panel always stays first.
- The install asks less. If oh-my-zsh is already on your machine, it does not offer the workdeck zsh. If you already have the JetBrains Mono font, the visual question is only about the theme.

## v2.5.2

### Português

- O painel com o relógio ficou mais organizado: os seus projetos no meio, e o workdeck numa faixa de uma linha embaixo, com a versão e os atalhos principais. Saíram o logo, a frase e as dicas que se espalhavam pela tela. O painel sem relógio continua igual.

### English

- The panel with the clock is tidier: your projects in the middle, and workdeck in a one-line strip at the bottom with the version and the main shortcuts. The logo, the tagline and the scattered hints are gone. The panel without the clock stays the same.

## v2.5.1

### Português

- A aba que você solta agora só muda o nome para a cor de destaque por um instante, sem o fundo aceso. Rode `Ctrl+b r` depois de atualizar.

### English

- A dropped tab now only turns its name to the accent color for a moment, without the lit background. Run `Ctrl+b r` after updating.

## v2.5.0

### Português

- Ao soltar uma aba arrastada, ela acende na cor de destaque e volta ao normal em seguida, para você ver onde ela pousou. Rode `Ctrl+b r` depois de atualizar.

### English

- When you drop a dragged tab, it lights up in the accent color and fades back, so you see where it landed. Run `Ctrl+b r` after updating.

## v2.4.2

### Português

- Correção: arrastar uma aba na barra não trocava os projetos de lugar. Agora a troca acontece quando você solta a aba em cima de outra, e o painel continua fixo em primeiro.
- Correção: no Mac, a instalação do relógio tclock falhava ao compilar. Agora ele compila em menos de um minuto com o Rust que você já tem.
- Correção: com o relógio tclock, o bloco de projetos do painel dizia que não havia nenhum projeto. Agora ele mostra os seus projetos, no seu idioma.

### English

- Fix: dragging a tab in the bar did not swap the projects. The swap now happens when you drop the tab on another one, and the panel stays first.
- Fix: on a Mac, installing the tclock clock failed while building. It now builds in under a minute with the Rust you already have.
- Fix: with the tclock clock, the projects block of the panel said there were no projects. It now shows your projects, in your language.

## v2.4.1

### Português

- Correção: arrastar a aba do painel, ou soltar outra aba em cima dele, tirava o painel da posição 1. Agora ele fica sempre em primeiro, e só os projetos trocam de lugar.

### English

- Fix: dragging the panel tab, or dropping another tab on it, moved the panel out of position 1. It now always stays first, and only the projects move.

## v2.4.0

### Português

- O `work review` passa a abrir sempre num painel separado, com um agente que começa do zero: ele lê só a mudança e o código em volta, sem a conversa que escreveu o código, e por isso não repete os mesmos pontos cegos. O `REVIEW_AGENT_CMD` continua escolhendo outro modelo ou outra IA para ele.
- O review no chat que você está usando continua disponível com `work review --chat`. O seu `REVIEW_COMMAND` (como `/bmad-code-review`) vira a primeira mensagem do agente no painel, ou vai para o chat com `--chat`.
- Sem nada por commitar, o review no painel cobre os commits que ainda não subiram, com qualquer agente.

### English

- `work review` now always opens a separate pane, with an agent that starts from scratch: it reads only the change and the code around it, without the conversation that wrote the code, so it does not repeat the same blind spots. `REVIEW_AGENT_CMD` still picks another model or AI for it.
- The review in the chat you are using is still there with `work review --chat`. Your `REVIEW_COMMAND` (such as `/bmad-code-review`) becomes the first message of the agent in the pane, or goes to the chat with `--chat`.
- With nothing to commit, the review in the pane covers the commits not pushed yet, with any agent.

## v2.3.0

### Português

- O painel pode ser o relógio tclock, do Akita: o relógio grande no alto e os blocos do painel, com o logo do workdeck primeiro, embaixo como widgets. A instalação pergunta se você quer (`--clock`); no Linux baixa o binário, no Mac compila com o `cargo`. Sem ele, o painel continua como antes.
- Arraste uma aba na barra de baixo para trocar a ordem dos projetos. A ordem nova fica salva no `projects.conf` e vale na próxima vez que o `work` abrir.
- No kitty, uma tecla global traz o workdeck por cima de qualquer app, pela janela de acesso rápido do kitty (você escolhe a tecla uma vez nos Ajustes do Sistema; a instalação mostra onde). O aviso de agente terminou também sai pelo kitty, e clicar nele traz o kitty para a frente.
- O kitty vira o app do workdeck: ao abrir, ele já entra no `work`. Janelas novas abrem um shell comum, e `KITTY_OPENS_WORK="no"` no `settings.conf` desliga. Nos outros terminais, o painel lembra que no kitty a experiência é mais completa.
- O kitty é o terminal recomendado, e os atalhos do workdeck (`⌘H`, `⌘P`, `⌘R`…) ficam só nele. A instalação pergunta se você quer os atalhos no kitty e, se ele ainda não estiver instalado, oferece baixar pelo instalador oficial, sem senha. O `work uninstall` tira a configuração dele e pergunta se o kitty sai também, com não como resposta padrão; no fim, mostra o logo e um até breve.
- Saíram as opções iTerm2 e Warp da instalação. Nesses terminais, e em qualquer outro, valem os atalhos do tmux (`Ctrl+b h`, `Shift+setas`). O `work update` remove o profile do iTerm2 que a v2.2.0 criou, se você não o editou.
- A instalação não pergunta mais qual agente de IA você usa: ela escolhe o que achar no PATH (`--agent` troca). As integrações também saíram das perguntas e continuam disponíveis com `--with`.

### English

- The panel can be Akita's tclock clock: a large clock on top and the panel blocks, with the workdeck logo first, below as widgets. The installer asks whether you want it (`--clock`); on Linux it downloads the binary, on a Mac it builds it with `cargo`. Without it, the panel stays as before.
- Drag a tab in the bottom bar to reorder your projects. The new order is saved to `projects.conf` and applies the next time `work` opens.
- In kitty, one global key brings workdeck up over any app, through kitty's quick access window (you pick the key once in System Settings; the installer shows where). The agent-finished alert also comes from kitty, and clicking it brings kitty to the front.
- kitty becomes the workdeck app: when it opens, it goes straight into `work`. New windows open a plain shell, and `KITTY_OPENS_WORK="no"` in `settings.conf` turns it off. In other terminals, the panel mentions that kitty gives the fuller experience.
- kitty is the recommended terminal, and the workdeck shortcuts (`⌘H`, `⌘P`, `⌘R`…) live only there. The installer asks whether you want the shortcuts in kitty and, if it is not installed yet, offers to download it with the official installer, without a password. `work uninstall` removes its configuration and asks whether kitty goes too, with no as the default answer; at the end, it shows the logo and a goodbye.
- The iTerm2 and Warp options are gone from the installer. In those terminals, and any other, the tmux shortcuts apply (`Ctrl+b h`, `Shift+arrows`). `work update` removes the iTerm2 profile v2.2.0 created, unless you edited it.
- The installer no longer asks which AI agent you use: it picks the one it finds in the PATH (`--agent` changes it). The integrations left the questions too and stay available with `--with`.

## v2.2.0

### Português

- Novos atalhos do workdeck no kitty e no iTerm2, uma letra para cada passo: `⌘H` menu, `⌘P` adicionar projeto, `⌘1…9` ir para o projeto, `⌘A` abrir o agente, `⌘T` abrir um terminal, `⌘Z` zoom, `⌘W` fechar o painel e `⌘R` work review. No kitty do Linux, as mesmas letras com `Ctrl+Shift`. Os atalhos `cmd` antigos (`cmd+d`, `cmd+enter`, `cmd+shift+…`) saíram; o `Ctrl+b` continua igual.
- O iTerm2 entrou nas opções da instalação, no Mac: o workdeck grava um profile **workdeck** com os atalhos, mesmo antes de o iTerm2 estar instalado. Escolha ele como padrão em Settings › Profiles. O `work uninstall` remove o profile.
- Dá para escolher mais de um terminal na instalação, como `1 2` ou `--terminal kitty,iterm`. O workdeck configura só os escolhidos e não instala nenhum.
- O menu, a barra e o painel mostram a tecla do menu do seu terminal (`⌘H`, `Ctrl+Shift+H` ou `Ctrl+b h`). No menu, as letras seguem os atalhos: `p` projeto, `a` agente, `t` terminal, `w` fechar.
- A instalação ganhou um visual novo: a versão no cabeçalho, o que está sendo feito ao lado do spinner e o logo do workdeck no fim.
- Correção: no Linux, com o Warp e sem o visual, o fim da instalação mostrava um título sem nada embaixo.

### English

- New workdeck shortcuts in kitty and iTerm2, one letter per step: `⌘H` menu, `⌘P` add a project, `⌘1…9` go to the project, `⌘A` open the agent, `⌘T` open a terminal, `⌘Z` zoom, `⌘W` close the pane and `⌘R` work review. In kitty on Linux, the same letters with `Ctrl+Shift`. The old `cmd` shortcuts (`cmd+d`, `cmd+enter`, `cmd+shift+…`) are gone; `Ctrl+b` stays the same.
- iTerm2 joins the install options on a Mac: workdeck writes a **workdeck** profile with the shortcuts, even before iTerm2 is installed. Pick it as the default in Settings › Profiles. `work uninstall` removes the profile.
- You can pick more than one terminal at install time, such as `1 2` or `--terminal kitty,iterm`. workdeck sets up only the ones you chose and installs none.
- The menu, the status bar and the panel show the menu key of your terminal (`⌘H`, `Ctrl+Shift+H` or `Ctrl+b h`). In the menu, the letters follow the shortcuts: `p` project, `a` agent, `t` terminal, `w` close.
- The installer has a new look: the version in the header, what is happening next to the spinner and the workdeck logo at the end.
- Fix: on Linux, with Warp and without the look, the end of the install showed a heading with nothing below it.

## v2.1.0

### Português

- O Linux volta a ser suportado: a instalação nova no Linux funciona de novo, como antes da v2.0.0.
- Se o terminal escolhido ainda não está instalado, a instalação grava a configuração dele mesmo assim e mostra onde baixar. Quando você instala o kitty, ele já abre com os atalhos do workdeck; antes, era preciso rodar a instalação de novo.
- A pergunta do terminal explica o que cada opção ganha, e "outro" virou "Terminal padrão": o Terminal do macOS, o do Linux ou qualquer outro.
- O fim da instalação só pede para fechar e abrir o terminal quando algo novo precisa ser carregado, como o zsh do workdeck ou o comando `work` no PATH.

### English

- Linux is supported again: new installs on Linux work, as before v2.0.0.
- If the terminal you chose is not installed yet, the installer writes its configuration anyway and tells you where to download it. When you install kitty, it opens with the workdeck shortcuts; before, you had to run the installer again.
- The terminal question explains what each option gives you, and "other" is now "Default terminal": the macOS one, the Linux one or any other.
- The end of the install only asks you to close and reopen the terminal when something new needs to load, such as the workdeck zsh or the `work` command in the PATH.

## v2.0.0

### Português

- O workdeck passa a rodar só no macOS. No Linux, a instalação nova para antes de gravar qualquer coisa, tanto pelo `get.sh` quanto pelo `install.sh`. No Windows, ela também para, sem mais apontar para o WSL.
- Quem já instalou no Linux continua usando e recebendo atualizações, com um aviso na instalação de que o Linux não tem mais suporte: sem testes nem correções específicas.

### English

- workdeck now runs only on macOS. On Linux, a new install stops before writing anything, through `get.sh` and through `install.sh`. On Windows it stops as well, and no longer points to WSL.
- Existing Linux installs keep working and getting updates, with a notice during the install that Linux is no longer supported: no Linux testing or fixes.

## v1.6.0

### Português

- O workdeck fala inglês ou português. Na primeira instalação, a primeira pergunta é o idioma, com o do sistema como padrão; `--lang en` ou `--lang pt-BR` responde sem perguntar, e a escolha fica como `LANGUAGE` no `settings.conf`. Quem já usa o workdeck responde uma vez, no próximo `work update`, com o português como padrão: Enter deixa tudo como estava.
- Seguem o idioma: o instalador, o comando `work`, o menu, o painel, a janela do painel (`painel` ou `panel`), os avisos da barra, o pedido de review que vai para o agente e este registro de mudanças, que agora traz cada versão nos dois idiomas. As integrações, o desinstalador e o `get.sh` ficam para a próxima versão.
- `work update --off` e `work update --on` ligam e desligam o aviso de versão nova; `--desligar` e `--ligar` continuam funcionando. `work --help` lista os comandos.
- A janela de cada projeto abre com o agente e um shell lado a lado, em todos os projetos, sempre que o `work` abre a sessão. Antes, ela abria com um painel só, ou com três no `PROJECT_LAYOUT="agent-server-shell"`, que agora também abre dois. Para voltar a um painel só, use `PROJECT_LAYOUT="none"` no `settings.conf`. O `Ctrl+b Enter` continua igual.
- Novo `REVIEW_AGENT_CMD` no `settings.conf`: escolhe o agente ou o modelo que faz o `work review`, como `claude --model opus`. O review roda no painel separado, embaixo do chat, e um modelo diferente do que escreveu o código não repete os mesmos pontos cegos.
- Rode `Ctrl+b r` e depois `work kill` e `work`, para a barra usar as frases novas e as janelas abrirem com os dois painéis.

### English

- workdeck speaks English or Portuguese. On the first install, the first question is the language, with the system language as the default; `--lang en` or `--lang pt-BR` answers without asking, and the choice is saved as `LANGUAGE` in `settings.conf`. If you already use workdeck, the next `work update` asks once, with Portuguese as the default: Enter keeps everything as it was.
- These follow the language: the installer, the `work` command, the menu, the panel, the panel window (`panel` or `painel`), the status bar messages, the review request sent to the agent and this changelog, which now has each version in both languages. The integrations, the uninstaller and `get.sh` come in the next version.
- `work update --off` and `work update --on` turn the new version notice off and on; `--desligar` and `--ligar` keep working. `work --help` lists the commands.
- Each project window opens with the agent and a shell side by side, in every project, whenever `work` opens the session. Before, it opened with a single pane, or with three under `PROJECT_LAYOUT="agent-server-shell"`, which now opens two as well. To go back to a single pane, use `PROJECT_LAYOUT="none"` in `settings.conf`. `Ctrl+b Enter` stays the same.
- New `REVIEW_AGENT_CMD` in `settings.conf`: picks the agent or model that runs `work review`, such as `claude --model opus`. The review runs in the separate pane below the chat, and a model other than the one that wrote the code does not repeat the same blind spots.
- Run `Ctrl+b r`, then `work kill` and `work`, so the status bar uses the new messages and the windows open with the two panes.

## v1.5.0

### Português

- O menu (`Ctrl+b h`) ganhou o item "Ligar o aviso quando um agente termina", que liga a notificação do sistema sem editar o `settings.conf`. Com o aviso ligado, o mesmo item aparece como "Desligar o aviso quando um agente termina".
- Correção: quando a conversa mencionava "esc to interrupt", o `work review` dizia que o Claude ainda estava trabalhando, e a ✦ não aparecia quando o Claude ou o Codex terminava. Agora só conta a linha de status do agente, perto do campo de mensagem.

### English

- The menu (`Ctrl+b h`) has a new item, "Turn on the alert when an agent finishes", which turns on the system notification without editing `settings.conf`. With the alert on, the same item reads "Turn off the alert when an agent finishes".
- Fix: when the conversation mentioned "esc to interrupt", `work review` said Claude was still working, and the ✦ did not show up when Claude or Codex finished. Now only the agent status line, near the message field, counts.

## v1.4.0

### Português

- A barra do tmux marca com uma ✦ roxa a janela em que um agente terminou ou parou para perguntar algo, enquanto você está em outra. Com vários agentes na mesma janela, a estrela continua uma só. Ela some quando você abre a janela ou quando os agentes voltam a trabalhar. No Claude Code e no Codex, o fim é detectado pelo "esc to interrupt" da tela deles; nos outros agentes, por 10 segundos sem mudança na tela. Antes, a ✦ só marcava a janela com o review aberto num painel.
- Novo `NOTIFY_AGENTS="yes"` no `settings.conf`: uma notificação do sistema avisa quando um agente termina numa janela que você não está olhando ("o claude terminou em api"). Vem desligado.
- A aba do painel aparece na cor de destaque do tema, para diferenciar das janelas de projeto (vale a partir do próximo `work` depois de um `work kill`).
- Rode `Ctrl+b r` depois de atualizar, para a barra usar a estrela nova, e `work` uma vez para o acompanhamento começar.

### English

- The tmux status bar marks with a purple ✦ the window where an agent finished or stopped to ask something, while you are in another one. With several agents in the same window, there is still a single star. It goes away when you open the window or when the agents start working again. For Claude Code and Codex, the end is detected through the "esc to interrupt" on their screen; for other agents, after 10 seconds without screen changes. Before, the ✦ only marked the window with the review open in a pane.
- New `NOTIFY_AGENTS="yes"` in `settings.conf`: a system notification tells you when an agent finishes in a window you are not looking at ("claude finished in api"). Off by default.
- The panel tab shows in the theme accent color, to set it apart from the project windows (applies from the next `work` after a `work kill`).
- Run `Ctrl+b r` after updating, so the status bar uses the new star, and `work` once to start tracking the agents.

## v1.3.1

### Português

- Correção: no macOS, se o `settings.conf` tivesse um comentário salvo com acentos em Latin-1 (por um editor antigo, por exemplo), nenhuma escolha era lida e o workdeck voltava aos padrões. Agora o arquivo é lido normalmente.

### English

- Fix: on macOS, if `settings.conf` had a comment saved with Latin-1 accents (by an old editor, for example), no choice was read and workdeck fell back to the defaults. The file is now read normally.

## v1.3.0

### Português

- Novo `PROJECT_LAYOUT="agent-server-shell"` no `settings.conf`: a janela de cada projeto já abre em três painéis, com o agente à esquerda, o servidor em cima à direita e um shell livre embaixo. O comando do agente (`AGENT_CMD`) e o do servidor (`SERVER_COMMAND` no `.workdeck/project.conf` do projeto) aparecem digitados, sem rodar: você aperta Enter onde for trabalhar. Vem desligado e vale para as janelas abertas depois de ligar.
- No Windows, a instalação para logo no começo, antes de gravar qualquer coisa, e explica como instalar pelo WSL.
- Correção: com o `ACTIVE_PANE="line"`, o `Ctrl+b Enter` não fechava a grade 2×2; agora o quarto painel vai para baixo do da esquerda também com o traço ligado.

### English

- New `PROJECT_LAYOUT="agent-server-shell"` in `settings.conf`: each project window opens in three panes, with the agent on the left, the server at the top right and a free shell below it. The agent command (`AGENT_CMD`) and the server command (`SERVER_COMMAND` in the project's `.workdeck/project.conf`) are typed but not run: you press Enter where you want to work. Off by default, and applies to windows opened after you turn it on.
- On Windows, the installer stops right at the start, before writing anything, and explains how to install through WSL.
- Fix: with `ACTIVE_PANE="line"`, `Ctrl+b Enter` did not close the 2×2 grid; the fourth pane now goes below the left one with the line on as well.

## v1.2.0

### Português

- `Ctrl+b Enter` e o "Dividir a tela" do menu montam uma grade sempre igual: o segundo painel abre ao lado, o terceiro embaixo do da direita e o quarto embaixo do da esquerda, fechando quatro painéis do mesmo tamanho. A partir do quinto, a janela vira uma grade igual. Os painéis que já existem não mudam de lugar. `Ctrl+b v` e `Ctrl+b -` continuam dividindo ao lado e embaixo, como antes. Rode `Ctrl+b r` depois de atualizar para a tecla nova valer na sessão aberta.

### English

- `Ctrl+b Enter` and "Split the screen" in the menu build the same grid every time: the second pane opens to the side, the third below the right one and the fourth below the left one, making four panes of the same size. From the fifth on, the window becomes an even grid. Existing panes do not move. `Ctrl+b v` and `Ctrl+b -` still split to the side and below, as before. Run `Ctrl+b r` after updating so the new key works in the open session.

## v1.1.2

### Português

- Correção: no Claude Code, o `work review` colava o `/code-review` mas não apertava Enter. A leitura da tela não reconhecia o campo de mensagem do Claude, que usa um espaço especial depois do `❯` e mostra uma sugestão apagada quando está vazio. Agora o review começa sozinho, como prometido na v1.1.1.

### English

- Fix: in Claude Code, `work review` pasted `/code-review` but did not press Enter. The screen reading did not recognize the Claude message field, which uses a special space after `❯` and shows a dimmed suggestion when empty. The review now starts on its own, as promised in v1.1.1.

## v1.1.1

### Português

- No Claude Code, o `work review` começa o review sozinho, sem você apertar Enter no chat. Ele só manda quando o Claude terminou: se ainda estiver trabalhando, com uma pergunta aberta ou com uma mensagem sua pela metade, não manda nada e diz o que falta.
- Correção: sem nada por commitar, o `work review` dizia que não havia o que revisar mesmo com commits que ainda não subiram. Agora, com o Claude aberto, ele manda o `/code-review`, que revisa esses commits.

### English

- In Claude Code, `work review` starts the review on its own, without you pressing Enter in the chat. It only sends it when Claude is done: if it is still working, has an open question or a half-written message of yours, it sends nothing and says what is missing.
- Fix: with nothing to commit, `work review` said there was nothing to review even with commits that were not pushed yet. Now, with Claude open, it sends `/code-review`, which reviews those commits.

## v1.1.0

### Português

- O `work review` usa o review do seu próprio agente. No Claude Code, ele cola o `/code-review` no chat que você está usando; você confere e aperta Enter, e os achados chegam ali, com o agente pronto para corrigir.
- Para usar outro review, como o do BMAD ou uma skill sua, ponha `REVIEW_COMMAND="/o-comando"` em `.workdeck/review.conf` no projeto (só um comando de barra, sem argumentos) ou no `settings.conf`, para todos. `work review --pane` abre o painel separado de antes, que continua valendo com `staged` e com agentes sem review próprio.
- As suas escolhas ficam num arquivo só, `~/.config/workdeck/settings.conf`, uma `CHAVE="valor"` por linha: terminal, tema, visual, agente, integrações, zsh e o aviso de versão nova. O `work update` junta os arquivos antigos nele sem perder nenhuma escolha. Pode editar à mão; a instalação só reescreve uma chave quando você pede com uma flag, como `--theme`.
- Novo `ACTIVE_PANE="line"` no `settings.conf`: um traço fino na cor de destaque do tema sobre o painel ativo, para saber onde está o foco com dois painéis lado a lado. Vem desligado; `Ctrl+b r` aplica, sem reiniciar a sessão.
- Correção: a checagem diária de versão nova voltou a funcionar. Desde a reorganização do código ela não rodava, e o `work` e o painel não avisavam de versões novas.

### English

- `work review` uses your own agent's review. In Claude Code, it pastes `/code-review` into the chat you are using; you check it and press Enter, and the findings arrive there, with the agent ready to fix them.
- To use another review, such as the BMAD one or a skill of yours, put `REVIEW_COMMAND="/the-command"` in `.workdeck/review.conf` in the project (only a slash command, without arguments) or in `settings.conf`, for every project. `work review --pane` opens the separate pane from before, which still applies with `staged` and with agents without their own review.
- Your choices live in a single file, `~/.config/workdeck/settings.conf`, one `KEY="value"` per line: terminal, theme, look, agent, integrations, zsh and the new version notice. `work update` folds the old files into it without losing any choice. You can edit it by hand; the installer only rewrites a key when you ask with a flag, such as `--theme`.
- New `ACTIVE_PANE="line"` in `settings.conf`: a thin line in the theme accent color over the active pane, to see where the focus is with two panes side by side. Off by default; `Ctrl+b r` applies it without restarting the session.
- Fix: the daily check for a new version works again. Since the code reorganization it did not run, and `work` and the panel did not tell you about new versions.

## v1.0.1

### Português

- O `work update` não trava mais quando uma versão é republicada com o mesmo nome: a busca de versões passa a aceitar a tag nova no lugar da antiga.
- `Option+Delete` volta a apagar a palavra inteira dentro do Claude Code e de outros agentes no tmux. No kitty, `Shift+Enter` pula a linha no agente em vez de enviar a mensagem, e só dentro do tmux.
- **`Alt+←` e `Alt+→` não trocam mais de painel**, para continuarem andando por palavras no shell e nos agentes. `Alt+↑` e `Alt+↓` seguem trocando de painel, e `Ctrl+b` com as setas troca em qualquer direção.
- Ao atualizar, a sessão aberta já passa a usar os atalhos novos depois de recarregar a configuração (`Ctrl+b r`); não precisa do `work kill`. No kitty, recarregue a configuração com `Ctrl+Cmd+,` ou abra o kitty de novo, senão o `Shift+Enter` não muda.

### English

- `work update` no longer gets stuck when a version is republished under the same name: the version lookup now accepts the new tag in place of the old one.
- `Option+Delete` deletes the whole word again inside Claude Code and other agents in tmux. In kitty, `Shift+Enter` adds a line in the agent instead of sending the message, and only inside tmux.
- **`Alt+←` and `Alt+→` no longer switch panes**, so they keep moving by words in the shell and in the agents. `Alt+↑` and `Alt+↓` still switch panes, and `Ctrl+b` with the arrows switches in any direction.
- When you update, the open session uses the new shortcuts after reloading the configuration (`Ctrl+b r`); no `work kill` needed. In kitty, reload the configuration with `Ctrl+Cmd+,` or reopen kitty, otherwise `Shift+Enter` does not change.

## v1.0.0

### Português

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

### English

workdeck is a framework for working with AI agents in the terminal, built on
tmux. This is the first version numbered from scratch; existing users get this
update normally and lose no choice.

- `work` opens a tmux session with one window per project and the workdeck panel. The session survives closing the terminal, and after a restart `work` opens the projects again.
- The everyday commands: `work`, `work add`, `work review`, `work update`, `work kill` and `work uninstall`. The menu (Ctrl+b h) lists the projects, the actions and the shortcuts.
- `work review` asks your AI agent to review the change before the commit, in a pane separate from the conversation that wrote the code, with a dot per finding: red for a bug to fix before the commit, orange for a concern that can wait and green for what is right, and a verdict at the end.
- The panel shows the branch and the changes of each project. Any executable in `~/.config/workdeck/panels/` becomes a block of the panel, and `chmod -x` turns a block off, including the shipped ones.
- Works in any terminal: tmux is the only dependency. The installer asks which terminal you use and offers its extras: in kitty, the `cmd` shortcuts and, if you want, the theme and the JetBrains Mono font; in Warp, the theme copied to its folder and where to pick the theme, the font and Option as Meta. workdeck does not install a terminal.
- Three themes (`catppuccin-mocha`, `nord` and `min-dark`) and the optional workdeck zsh, with oh-my-zsh and zinit.
- Optional integrations with `--with`: BMAD, Spec Kit and ai-memory.
- One-line install with `get.sh`, fully reversible: what it writes to your files sits between markers, and `work uninstall` undoes everything.
- README and guides in English and Portuguese. What shows up in the terminal is in Portuguese.
