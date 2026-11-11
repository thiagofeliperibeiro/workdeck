msg_settings_header_1="# Configurações do workdeck. Cada linha é CHAVE=\"valor\"; linhas com # no começo são comentários."
msg_settings_header_2="# A instalação lembra aqui as suas escolhas, e você pode editar à mão."
msg_settings_active_pane_1="# Destaque do painel ativo: \"none\" (padrão, o visual do tema) ou \"line\""
msg_settings_active_pane_2="# (traço fino no topo do painel ativo). Ctrl+b r aplica."
msg_settings_layout_1="# Cada janela de projeto abre com um painel só, para o agente. \"agent-shell\" acrescenta um shell ao lado,"
msg_settings_layout_2="# onde o SERVER_COMMAND do .workdeck/project.conf do projeto aparece digitado, sem rodar."
msg_settings_layout_3="# Vale para as janelas abertas depois de mudar."
msg_settings_notify_agents="# Notificação do sistema quando um agente termina numa janela que você não está olhando."

msg_work_help="Os comandos são:
  work                abre a sessão, ou volta para ela
  work add <pasta>    acrescenta um projeto
  work update         atualiza o workdeck
  work kill           fecha a sessão inteira
  work uninstall      desinstala tudo o que o workdeck instalou"
msg_work_unknown="não conheço 'work %s'."
msg_update_no_copy="não achei a cópia do workdeck em %s."
msg_update_no_copy_hint="rode o ./install.sh de um clone do repositório uma vez, e o work update passa a funcionar."
msg_update_unreachable="não consegui falar com o repositório do workdeck; tente de novo mais tarde."
msg_update_none_published="ainda não há versão publicada do workdeck."
msg_update_up_to_date="você está na %s, a mais nova."
msg_update_no_version="sem versão"
msg_update_new_version="uma versão nova"
msg_update_changes="O que mudou"
msg_update_ask="Atualizar agora? [S/n] "
msg_update_later="tudo bem; quando quiser: work update"
msg_update_done="✓ workdeck atualizado para %s"
msg_update_notify_off="o work não vai mais perguntar sobre versões novas; work update continua funcionando."
msg_update_notify_on="o work volta a avisar sobre versões novas."
msg_menu_add="Adicionar um projeto…"
msg_menu_add_prompt="caminho do projeto (Esc cancela):"
msg_menu_notify_on="Ligar o aviso quando um agente termina"
msg_menu_notify_off="Desligar o aviso quando um agente termina"
msg_menu_update="Atualizar o workdeck"
msg_menu_press_key="aperte qualquer tecla para fechar"
msg_menu_split="Abrir um terminal num painel novo"
msg_menu_zoom="Zoom no painel (de novo volta)"
msg_menu_close_pane="Fechar este painel"
msg_menu_key_windows="Shift ← →     projeto anterior / próximo"
msg_menu_key_panes="Shift ↑ ↓     painel anterior / próximo"
msg_menu_key_number="Ctrl+b 1…9    vai direto para a janela"
msg_menu_key_detach="Ctrl+b d      sai e deixa a sessão rodando"
msg_menu_key_mouse="mouse         clica na barra, arrasta a borda"
msg_menu_close_hint="q ou Esc fecha o menu"
msg_layout_invalid="PROJECT_LAYOUT=\"%s\" não existe no settings.conf; use agent-shell ou none. As janelas abrem com um painel só."
msg_active_pane_invalid="workdeck: ACTIVE_PANE=\"%s\" inválido; use none ou line"
msg_agent_done="o %s terminou em %s"
msg_notify_agents_off="aviso desligado: só a ✦ na barra marca quando um agente termina"
msg_notify_agents_on="aviso ligado: uma notificação do sistema avisa quando um agente termina em outra janela"
msg_settings_not_writable="não consegui gravar em %s; confira se o arquivo pode ser alterado"
msg_add_missing="não achei a pasta: %s"
msg_add_exists="%s já está no seu work, como %s"
msg_add_done="%s entrou no seu work como %s"
msg_add_window_open="a janela %s já está aberta na sessão %s"
msg_kill_done="sessão %s fechada"
msg_kill_none="nenhuma sessão %s aberta"
msg_uninstall_missing="não achei o desinstalador em %s"
msg_uninstall_intro="O work uninstall desinstala tudo o que o workdeck instalou:
  - os blocos do workdeck no .zshrc, no .tmux.conf e no kitty.conf
  - o comando work e o código em %s
  - o zsh do workdeck (oh-my-zsh e zinit), a fonte e o tclock, se foi ele que instalou;
    o kitty sai só se você responder que sim
  - a sua config em %s: projetos, painéis e escolhas

O que já era seu antes da instalação fica. Para ver sem apagar: work uninstall --dry-run
Para tirar só os blocos e manter a config: bash %s/uninstall.sh
"
msg_uninstall_ask="Desinstalar tudo? [s/N] "
msg_nothing_done="nada feito"
msg_no_projects="Seu work ainda não tem projetos. Adicione o primeiro:

  work add ~/caminho/do/projeto      (Tab completa o caminho)"
msg_skip_project="pulando %s: %s não existe"

msg_install_help="workdeck — instalador. macOS e Linux.

  ./install.sh                      instala com o tema padrão
  ./install.sh --lang en            escolhe o idioma (en ou pt-BR) sem perguntar
  ./install.sh --theme nord         escolhe um tema de themes/
  ./install.sh --agent claude       define o seu agente de IA
  ./install.sh --zsh                instala o oh-my-zsh e o zinit sem perguntar
  ./install.sh --with ai-memory     ativa integrações opcionais (vírgula separa)
  ./install.sh --list-integrations  mostra as integrações disponíveis e sai
  ./install.sh --terminal kitty     atalhos do workdeck no kitty sem perguntar (other: sem kitty)
  ./install.sh --visual             instala o tema e a fonte no terminal, sem perguntar
  ./install.sh --clock              painel com o relógio tclock, sem perguntar (--no-clock recusa)
  ./install.sh --no-visual          no terminal, só os atalhos
  ./install.sh --yes                não pergunta nada; usa os padrões
  ./install.sh --no-deps            não instala nada pelo gerenciador de pacotes
  ./install.sh --no-reload          não recarrega o tmux no fim
  ./install.sh --dry-run            só mostra o que faria

É idempotente: rodar de novo atualiza em vez de duplicar. O que ele escreve
nos seus arquivos fica entre marcadores >>> workdeck >>>, e o uninstall.sh
remove exatamente esse trecho."
msg_install_needs_value="%s precisa de um valor"
msg_install_bad_terminal="terminal '%s' não existe. Use kitty ou other"
msg_install_bad_lang="idioma '%s' não existe. Disponíveis: en, pt-BR"
msg_install_unknown_option="opção desconhecida: %s"
msg_install_not_regular="%s não é um arquivo comum; não mexi nele"
msg_install_backup="cópia do original em %s"
msg_install_dry_block="[dry-run] atualizaria o bloco em %s"
msg_install_bad_theme="tema '%s' não existe. Disponíveis:"
msg_install_header_plain="workdeck → %s, tema %s"
msg_install_kitty_full="kitty.conf — atalhos, tema e fonte"
msg_install_kitty_keys="kitty.conf — atalhos"
msg_install_other_terminal="outro terminal"
msg_install_ask_number="Número (Enter para %s): "
msg_install_ask_theme="Você já tem a fonte JetBrains Mono. Quer também o tema do workdeck no %s? [s/N] "
msg_install_ask_visual="Quer também o tema e a fonte JetBrains Mono do workdeck no %s? [s/N] "
msg_install_kitty_missing="o kitty ainda não está instalado; os atalhos já estão no kitty.conf. Instale por %s e ele abre pronto."
msg_install_kitty_summary_full="kitty com atalhos, tema e fonte"
msg_install_kitty_summary_keys="kitty com atalhos"
msg_install_no_terminal_changes="sem kitty: os atalhos do tmux funcionam em qualquer terminal"
msg_install_font_present="fonte JetBrains Mono já instalada"
msg_install_font_no_deps="fonte JetBrains Mono não instalada (--no-deps)"
msg_install_dry_font="[dry-run] baixaria a fonte JetBrains Mono para %s"
msg_install_font_no_tools="sem curl ou unzip; a fonte JetBrains Mono fica para depois"
msg_install_font_done="fonte JetBrains Mono instalada em %s"
msg_install_font_failed="não consegui baixar a fonte JetBrains Mono; o resto segue normal"
msg_install_step_deps="dependências"
msg_install_tmux_present="tmux já instalado"
msg_install_missing_no_deps="faltando: %s — instale por conta (--no-deps)"
msg_install_unknown_pkg="não reconheci o gerenciador de pacotes; instale: %s"
msg_install_pkg_failed="não consegui instalar %s pelo %s"
msg_install_code_copy="cópia do código em %s, para o work update"
msg_install_not_clone="%s não é um clone do git; o work update não vai funcionar"
msg_install_script_moved="%s saiu de %s: só o work fica no PATH"
msg_install_step_scripts="scripts"
msg_install_work_exists="work — já existe um work que não é do workdeck; não substituí"
msg_install_not_in_path="atenção: %s não está no PATH — o bloco do shell resolve isso"
msg_install_scripts_summary="work em %s"
msg_install_old_panel="painel antigo %s removido"
msg_install_panel="painel %s"
msg_install_panel_off="painel %s desligado por você — não toquei nele"
msg_install_panel_updated="painel %s atualizado"
msg_install_panel_edited="painel %s foi editado por você — não toquei nele"
msg_install_step_config="config"
msg_install_projects_exists="projects.conf já existe — não toquei nele"
msg_install_projects_hint="projetos: adicione com work add <caminho>"
msg_install_git_review_removed="configuração antiga do git-review removida"
msg_install_step_tmux="tmux e terminal"
msg_install_tmux_summary="Ctrl+b, mouse e atalhos em Alt"
msg_install_tmux_done="tmux.conf — Ctrl+b, mouse e atalhos em Alt"
msg_install_zsh_custom="zsh: você já tem plugins (oh-my-zsh, zinit ou outros); não mexi"
msg_install_ask_zsh="Quer o zsh do workdeck? Sugestões enquanto digita, cores nos comandos
  e mais completar com Tab. [S/n] "
msg_install_dry_zsh="[dry-run] instalaria o zsh do workdeck"
msg_install_zsh_failed="não consegui instalar o zsh; instale pelo gerenciador e rode a instalação de novo com --zsh"
msg_install_ask_chsh="Usar o zsh como o seu shell padrão? Pede a sua senha. [S/n] "
msg_install_chsh_failed="não troquei o shell padrão; dá para fazer depois com: chsh -s %s"
msg_install_omz_failed="não consegui baixar o oh-my-zsh ou o zinit; rode a instalação de novo com --zsh mais tarde"
msg_install_step_shell="shell"
msg_install_unknown_shell="shell '%s' não reconhecido — adicione à mão: source %s"
msg_install_step_agent="agente de IA"
msg_install_agent="agente: %s"
msg_install_agent_set="agente já configurado: %s"
msg_install_no_agent="nenhum agente de IA encontrado no PATH"
msg_install_no_agent_summary="nenhum no PATH"
msg_install_unknown_integration="não conheço a integração '%s'"
msg_install_integration_present="%s já está instalada"
msg_install_dry_integration="[dry-run] instalaria %s"
msg_install_step_integrations="integrações"
msg_install_integrations_before="escolhidas antes: %s; para ver de novo: rode a instalação de novo com --with <nome>"
msg_install_integrations_none="nenhuma; para ligar depois: rode a instalação de novo com --with <nome>"
msg_install_integrations_none_summary="nenhuma (--with <nome>)"
msg_install_not_saved=" (detectado, não salvo)"
msg_install_yes="sim"
msg_install_no="não"
msg_install_choices="Suas escolhas, que a instalação lembra nas próximas vezes:"
msg_install_choice_language="idioma"
msg_install_choice_language_hint="para mudar: ./install.sh --lang en|pt-BR"
msg_install_choice_terminal_hint="para mudar: ./install.sh --terminal kitty ou --terminal other"
msg_install_choice_visual_hint="para mudar: ./install.sh --visual (tema e fonte) ou --no-visual"
msg_install_tmux_reloaded="tmux recarregado"
msg_install_restart_terminal="Feche e abra o %s para carregar o zsh e o visual novos."
msg_install_done_fancy="✓ pronto em %ss"
msg_install_done="Pronto."
msg_install_open_kitty_restart="feche e abra o kitty"
msg_install_open_kitty_restart_hint="carrega o zsh, o visual e os comandos do workdeck"
msg_install_open_warp_restart="feche e abra o Warp"
msg_install_open_terminal_restart_hint="carrega o zsh e os comandos do workdeck"
msg_install_open_kitty="abra o kitty"
msg_install_open_kitty_visual_hint="com o tema, a fonte e os atalhos cmd do workdeck"
msg_install_open_kitty_hint="com os atalhos cmd do workdeck"
msg_install_open_terminal_restart="feche e abra o terminal"
msg_install_now="Agora:"
msg_install_work_hint="abre o painel, que mostra como adicionar os projetos"
msg_install_navigation="  Para navegar: Shift+← / Shift+→ troca de projeto e Shift+↑ / Shift+↓ troca de
  painel. Clicar na barra também funciona.
  Ajuda a qualquer hora: %s dentro do work."
msg_install_windows="O workdeck roda em macOS e Linux. No Windows, use pelo WSL: abra o Ubuntu do WSL e rode a instalação de lá."
msg_install_ask_language="Em que idioma o workdeck mostra as mensagens?"

msg_agent_none="nenhum agente definido"
msg_agent_is_workdeck="'%s' é um comando do workdeck, não um agente"
msg_agent_not_in_path="'%s' não está no PATH"
msg_agent_set_is_workdeck="'%s' é um comando do workdeck, não um agente de IA."
msg_agent_set_not_in_path="'%s' não está no PATH."
msg_agent_set_done="agente definido: %s"

msg_drop_panel_fixed="O painel fica sempre em primeiro: arraste só entre os projetos"
msg_window_panel="painel"
msg_panel_title_20_projetos="Projetos"
msg_panel_help="work-panel mostra a saída de vários comandos em um painel, atualizando sozinho.

  work-panel            atualiza a cada 60s
  work-panel 10         atualiza a cada 10s
  work-panel --once     imprime uma vez e sai

Cada painel é um executável em ~/.config/workdeck/panels/. O nome do arquivo
vira o título, e a ordem é alfabética: use um prefixo numérico para ordenar
(10-docker, 20-git). Qualquer coisa que imprima texto serve."
msg_panel_bad_interval="intervalo inválido: %s"
msg_panel_none="Nenhum painel ainda."
msg_panel_create="Crie um executável em %s/, qualquer coisa que imprima texto:"
msg_panel_empty="%s existe mas não tem nenhum executável."
msg_panel_chmod="Lembre do chmod +x."
msg_panel_projects_none="nenhum projeto ainda"
msg_panel_no_git="sem git"
msg_panel_changed="● %s alterado(s)"
msg_panel_clean="✓ limpo"
msg_panel_projects="projetos"
msg_panel_projects_zero="nenhum ainda"
msg_panel_no_version="sem versão"
msg_panel_tagline="terminal para agentes de IA"
msg_panel_start="%sPara começar%s, no terminal aqui embaixo:"
msg_panel_add_project="work add ~/projeto"
msg_panel_add_project_hint="cada projeto vira uma janela; Tab completa o caminho"
msg_panel_outside_kitty="%sNo kitty%s, o workdeck abre direto e tem atalhos de uma letra. Aqui, use Ctrl+b h."
msg_panel_menu_hint="%s abre o menu: projetos, agente e terminal"
msg_panel_custom_hint="Para pôr o seu no painel: um executável em ~/.config/workdeck/panels/"
msg_panel_guide="  guia: github.com/thiagofeliperibeiro/workdeck/blob/main/docs/panels.pt-BR.md"

msg_tmux_unused_key="tecla sem uso no workdeck — Ctrl+b h abre o menu"
msg_tmux_reloaded="tmux.conf recarregado"
msg_install_zsh_summary="oh-my-zsh (robbyrussell) e zinit"
msg_changelog_heading="Português"
msg_install_other_summary="outro terminal, atalhos do tmux"
msg_install_open_kitty_reload_hint="carrega os atalhos e os comandos do workdeck"
msg_install_open_new_window="abra uma janela nova"
msg_install_open_new_window_hint="carrega os comandos do workdeck"
msg_menu_agent="Abrir o agente num painel novo"
msg_menu_key_terminal_1="%sH menu    %sP projeto    %sA agente    %sT terminal"
msg_menu_key_terminal_2="%sZ zoom    %sW fechar     %s1…9 projeto"
msg_agent_pane_none="nenhum agente definido: rode ./install.sh --agent claude (ou o seu agente)"
msg_install_ask_kitty="Quer os atalhos do workdeck no kitty (⌘H menu, ⌘P projeto, ⌘A agente…)?
Se o kitty ainda não estiver instalado, a configuração já fica pronta."
msg_install_ask_kitty_linux="Quer os atalhos do workdeck no kitty (Ctrl+Shift+H menu, Ctrl+Shift+P projeto…)?
Se o kitty ainda não estiver instalado, a configuração já fica pronta."
msg_install_ask_kitty_default_yes="[S/n] "
msg_install_ask_kitty_default_no="[s/N] "
msg_install_iterm_retired="profile workdeck do iTerm2 removido: os atalhos do workdeck agora são só do kitty"
msg_install_agent_others="também no PATH: %s; para trocar: ./install.sh --agent <comando>"
msg_install_agent_detected_summary="%s, detectado no PATH"
msg_install_claude_statusline="limites do Claude na barra: statusLine configurada em %s"
msg_install_claude_statusline_chained="limites do Claude na barra: statusLine configurada em %s; a sua statusline continua aparecendo no Claude"
msg_install_claude_statusline_set="limites do Claude na barra: já configurado"
msg_install_claude_settings_unreadable="%s não é um JSON válido; não mexi nele, então os limites do Claude ficam fora da barra"
msg_install_dry_claude_settings="configuraria a statusLine em %s"
msg_install_ask_download_kitty="O kitty ainda não está instalado. Baixar agora pelo instalador oficial (sem senha)? [S/n] "
msg_install_kitty_downloading="baixando o kitty pelo instalador oficial…"
msg_install_kitty_installed="kitty instalado em %s; o work uninstall pergunta antes de remover"
msg_install_kitty_download_failed="não consegui instalar o kitty; baixe por %s, os atalhos já estão no kitty.conf"
msg_install_kitty_present="o kitty já está instalado; abra o work nele para a melhor experiência"
msg_install_kitty_session="o kitty abre direto no work (KITTY_OPENS_WORK=\"no\" no settings.conf desliga)"
msg_settings_kitty_opens_work="# O kitty abre direto no work. \"no\" desliga; rode a instalação de novo para aplicar."
msg_panel_kitty_elsewhere="Aqui, use Ctrl+b h; os atalhos do workdeck ficam no kitty."
msg_install_quick_access_todo="Para trazer o workdeck de qualquer app com uma tecla, falta um passo:"
msg_install_quick_access_steps="       atalho    Ajustes do Sistema › Teclado › Atalhos de Teclado › Serviços › Geral
                 › \"Quick access to kitty\", e escolha a tecla"
msg_install_quick_access_steps_linux="       atalho    nas configurações de teclado do sistema, ligue uma tecla ao comando
                 kitten quick-access-terminal"
msg_uninstall_ask_kitty="Remover o kitty também? A configuração dele já saiu. [s/N] "
msg_uninstall_kitty_kept="o kitty continua instalado; só a configuração do workdeck saiu dele"
msg_uninstall_kitty_removed="kitty removido de %s"
msg_uninstall_kitty_failed="não consegui remover %s; apague à mão se quiser"
msg_uninstall_goodbye="até breve."
msg_install_ask_clock="Quer o painel com o relógio tclock (o relógio no alto e os blocos do painel embaixo)? [s/N] "
msg_install_clock_present="tclock já instalado; o painel usa ele"
msg_install_clock_no_deps="tclock não instalado (--no-deps); o painel fica no modo de texto"
msg_install_dry_clock="[dry-run] instalaria o tclock"
msg_install_clock_needs_rust="o tclock no Mac precisa do Rust: rode brew install rust e a instalação de novo; até lá, o painel fica no modo de texto"
msg_install_clock_compiling="compilando o tclock com o cargo (leva alguns minutos)…"
msg_install_clock_downloading="baixando o tclock…"
msg_install_clock_installed="tclock instalado em %s"
msg_install_clock_failed="não consegui instalar o tclock (%s); o painel fica no modo de texto"
msg_settings_panel_clock="# Painel com o relógio tclock no alto e os blocos embaixo. Precisa do tclock instalado."
msg_install_ask_clock_mac="Quer o painel com o relógio tclock (o relógio no alto e os blocos embaixo)?
No Mac, ele é compilado com o Rust que você já tem e leva alguns minutos. [s/N] "
msg_install_ask_clock_mac_no_rust="Quer o painel com o relógio tclock (o relógio no alto e os blocos embaixo)?
No Mac, ele precisa do Rust, que não está instalado: rode brew install rust e a
instalação de novo para ter o relógio. [s/N] "
msg_panel_compact_keys="%sH menu  ·  %sP projeto  ·  %sA agente"
msg_panel_compact_menu="%s abre o menu"
