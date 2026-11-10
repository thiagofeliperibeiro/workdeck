tmux_session() { tmux "$@"; }

test_first_work_opens_panel_with_terminal() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_work_in_terminal work
  wait_for tmux_session has-session -t work || fail "the work session did not open"
  wait_for sh -c "tmux list-panes -t work:painel -F '#{@role}' | grep -qx TERMINAL" || fail "the terminal below the panel did not appear"
  sleep 1
  roles="$(tmux list-panes -t work:painel -F '#{@role}:#{pane_dead}' | tr '\n' ' ')"
  assert_equal "$roles" "PANEL:0 TERMINAL:0 " "panes in the panel window"
}

test_work_add_creates_the_project_window() {
  install_workdeck >/dev/null || fail "install exited with an error"
  mkdir -p "$HOME/api"
  work add "$HOME/api" >/dev/null || fail "work add exited with an error"
  assert "the project is in projects.conf" grep -q "^api|" "$CONFIG/projects.conf"
  open_work_in_terminal work
  wait_for sh -c "tmux list-windows -t work -F '#W' | grep -qx api" || fail "the project window did not open"
  assert_equal "$(tmux list-windows -t work -F '#W' | tr '\n' ' ')" "painel api " "windows"
}

test_menu_says_how_to_close() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_work_in_terminal work
  wait_for sh -c "tmux list-clients -t work | grep -q ." || fail "no terminal attached to the session"
  client="$(tmux list-clients -t work -F '#{client_name}' | head -1)"
  WD_MENU_LOG="$BASE/menu" work _menu "$client" "$(tmux display -p -t work:painel '#{pane_id}')"
  assert_contains "$(cat "$BASE/menu")" "-q ou Esc fecha o menu"
  assert_contains "$(cat "$BASE/menu")" "painel"
  assert_contains "$(cat "$BASE/menu")" "Remover um projeto…"
}

test_work_without_code_explains_what_to_do() {
  install_workdeck >/dev/null || fail "install exited with an error"
  rm -rf "$CODE"
  if output="$(work 2>&1)"; then fail "work should fail without the code"; fi
  assert_contains "$output" "o código do workdeck não está em"
  assert_contains "$output" "https://workdeck.dev/install"
}

project_with_server_command() {
  mkdir -p "$HOME/api/.workdeck"
  echo 'SERVER_COMMAND="echo servidor-no-ar"' > "$HOME/api/.workdeck/project.conf"
}

test_project_layout_types_only_the_server_command() {
  install_workdeck >/dev/null || fail "install exited with an error"
  echo 'AGENT_CMD="echo agente-no-ar"' >> "$CONFIG/settings.conf"
  echo 'PROJECT_LAYOUT="agent-shell"' >> "$CONFIG/settings.conf"
  project_with_server_command
  work add "$HOME/api" >/dev/null || fail "work add exited with an error"
  open_work_in_terminal work
  wait_for sh -c "[ \"\$(tmux list-panes -t work:api 2>/dev/null | wc -l | tr -d ' ')\" = 2 ]" || fail "the project window did not get two panes: $(tmux list-panes -t work:api 2>&1)"
  sleep 0.5
  assert_equal "$(tmux list-panes -t work:api | wc -l | tr -d ' ')" 2 "panes in the project window"
  panes="$(tmux list-panes -t work:api -F '#{pane_left},#{pane_top} #{pane_id}' | sort -n)"
  agent="$(printf '%s\n' "$panes" | awk '$1 == "0,0" {print $2}')"
  server="$(printf '%s\n' "$panes" | awk -F'[ ,]' '$1 > 0 && $2 == 0 {print $3}')"
  assert "the agent pane is on the left" test -n "$agent"
  assert "the shell pane is on the right" test -n "$server"
  wait_for sh -c "tmux capture-pane -p -t '$server' | grep -q 'echo servidor-no-ar'" || fail "the server command was not typed: $(tmux capture-pane -p -t "$server")"
  sleep 1.5
  assert_equal "$(tmux capture-pane -p -t "$agent" | grep -c 'agente-no-ar' || true)" 0 "the agent command was typed"
  assert_equal "$(tmux capture-pane -p -t "$server" | grep -cx 'servidor-no-ar' || true)" 0 "the server command ran"
}

open_layout_with_project_conf() {
  echo 'PROJECT_LAYOUT="agent-server-shell"' >> "$CONFIG/settings.conf"
  mkdir -p "$HOME/api/.workdeck"
  printf '%b' "$1" > "$HOME/api/.workdeck/project.conf"
  open_work_in_terminal work
  wait_for tmux_session has-session -t work || fail "the work session did not open"
  work add "$HOME/api" >/dev/null 2>&1
  wait_for sh -c "[ \"\$(tmux list-panes -t work:api 2>/dev/null | wc -l | tr -d ' ')\" = 2 ]" || fail "the project window did not get two panes"
  SERVER_PANE="$(tmux list-panes -t work:api -F '#{pane_left},#{pane_top} #{pane_id}' | awk -F'[ ,]' '$1 > 0 && $2 == 0 {print $3}')"
}

test_project_layout_never_runs_a_hidden_enter() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_layout_with_project_conf 'SERVER_COMMAND="echo um\recho dois"\r\n'
  wait_for sh -c "tmux capture-pane -p -t '$SERVER_PANE' | grep -q 'echo um'" || fail "the server command was not typed: $(tmux capture-pane -p -t "$SERVER_PANE")"
  sleep 1.5
  assert_equal "$(tmux capture-pane -p -t "$SERVER_PANE" | grep -cxE 'um|dois|umecho dois' || true)" 0 "lines printed by a command that ran"
}

test_project_layout_ignores_a_value_with_a_trailing_comment() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_layout_with_project_conf 'SERVER_COMMAND="npm run dev" # api\n'
  sleep 1.5
  assert_not_contains "$(tmux capture-pane -p -t "$SERVER_PANE")" "npm run dev" "the server pane"
}

test_project_layout_warns_about_an_unknown_value() {
  install_workdeck >/dev/null || fail "install exited with an error"
  echo 'PROJECT_LAYOUT="agent-server-terminal"' >> "$CONFIG/settings.conf"
  open_work_in_terminal work
  wait_for tmux_session has-session -t work || fail "the work session did not open"
  mkdir -p "$HOME/api"
  assert_contains "$(work add "$HOME/api" 2>&1)" "PROJECT_LAYOUT=\"agent-server-terminal\" não existe"
}

test_project_layout_opens_a_single_pane_by_default() {
  install_workdeck >/dev/null || fail "install exited with an error"
  mkdir -p "$HOME/api"
  work add "$HOME/api" >/dev/null || fail "work add exited with an error"
  open_work_in_terminal work
  wait_for sh -c "tmux list-windows -t work -F '#W' | grep -qx api" || fail "the project window did not open"
  sleep 0.5
  assert_equal "$(tmux list-panes -t work:api | wc -l | tr -d ' ')" 1 "panes in the project window"
}

test_project_layout_applies_to_work_add_in_an_open_session() {
  install_workdeck >/dev/null || fail "install exited with an error"
  echo 'PROJECT_LAYOUT="agent-server-shell"' >> "$CONFIG/settings.conf"
  open_work_in_terminal work
  wait_for tmux_session has-session -t work || fail "the work session did not open"
  mkdir -p "$HOME/api"
  work add "$HOME/api" >/dev/null || fail "work add exited with an error"
  wait_for sh -c "[ \"\$(tmux list-panes -t work:api 2>/dev/null | wc -l | tr -d ' ')\" = 2 ]" || fail "the new window did not get two panes"
}

test_menu_toggles_the_agent_notification() {
  install_workdeck >/dev/null || fail "install exited with an error"
  open_work_in_terminal work
  wait_for sh -c "tmux list-clients -t work | grep -q ." || fail "no terminal attached to the session"
  client="$(tmux list-clients -t work -F '#{client_name}' | head -1)"
  pane="$(tmux display -p -t work:painel '#{pane_id}')"
  WD_MENU_LOG="$BASE/menu" work _menu "$client" "$pane"
  assert_contains "$(cat "$BASE/menu")" "Ligar o aviso quando um agente termina"
  echo 'NOTIFY_AGENTS="yes"' >> "$CONFIG/settings.conf"
  WD_MENU_LOG="$BASE/menu" work _menu "$client" "$pane"
  assert_contains "$(cat "$BASE/menu")" "Desligar o aviso quando um agente termina"
}

drag_session() {
  install_workdeck >/dev/null || fail "install exited with an error"
  mkdir -p "$HOME/api" "$HOME/web"
  printf 'painel|~|work-panel\napi|~/api\nweb|~/web\n' > "$CONFIG/projects.conf"
  tmux new-session -d -s work -n painel
  tmux set -w -t work:painel @wd_panel 1
  API_WIN="$(tmux new-window -d -P -F '#{window_id}' -t work: -n api -c "$HOME/api")"
  tmux set -w -t "$API_WIN" @project "$HOME/api"
  WEB_WIN="$(tmux new-window -d -P -F '#{window_id}' -t work: -n web -c "$HOME/web")"
  tmux set -w -t "$WEB_WIN" @project "$HOME/web"
}

test_dragging_a_tab_saves_the_project_order() {
  drag_session
  tmux swap-window -d -s "$API_WIN" -t "$WEB_WIN"
  work _save-order
  assert_equal "$(tr '\n' ' ' < "$CONFIG/projects.conf")" "painel|~|work-panel web|~/web api|~/api " "projects.conf"
}

test_dragging_keeps_the_panel_first() {
  drag_session
  tmux swap-window -d -s work:painel -t "$API_WIN"
  work _save-order
  assert_equal "$(tmux list-windows -t work -F '#W' | head -1)" painel "the first window"
  assert_equal "$(head -1 "$CONFIG/projects.conf")" "painel|~|work-panel" "the first line of projects.conf"
}

remove_session() {
  install_workdeck >/dev/null || fail "install exited with an error"
  mkdir -p "$HOME/api" "$HOME/web"
  printf 'painel|~|work-panel\napi|~/api\nold|~/gone\nweb|~/web\n' > "$CONFIG/projects.conf"
  tmux new-session -d -s work -n painel
  tmux set -w -t work:painel @wd_panel 1
  API_WIN="$(tmux new-window -d -P -F '#{window_id}' -t work: -n api -c "$HOME/api")"
  tmux set -w -t "$API_WIN" @project "$HOME/api"
}

test_work_remove_drops_the_project_and_closes_its_window() {
  remove_session
  output="$(work remove api 2>&1)" || fail "work remove exited with an error: $output"
  assert_contains "$output" "api saiu do seu work"
  assert_equal "$(tr '\n' ' ' < "$CONFIG/projects.conf")" "painel|~|work-panel old|~/gone web|~/web " "projects.conf"
  assert_equal "$(tmux list-windows -t work -F '#W' | tr '\n' ' ')" "painel " "windows"
}

test_work_remove_drops_a_project_whose_folder_is_gone() {
  remove_session
  work remove old >/dev/null 2>&1 || fail "work remove exited with an error"
  assert_equal "$(tr '\n' ' ' < "$CONFIG/projects.conf")" "painel|~|work-panel api|~/api web|~/web " "projects.conf"
}

test_work_remove_of_an_unknown_name_lists_the_projects() {
  remove_session
  if output="$(work remove nada 2>&1)"; then fail "work remove should fail for an unknown name"; fi
  assert_contains "$output" "não achei o projeto nada no seu work"
  assert_contains "$output" "api, old, web"
  assert_equal "$(wc -l < "$CONFIG/projects.conf" | tr -d ' ')" 4 "lines in projects.conf"
}

test_remove_menu_lists_projects_and_flags_removed_folders() {
  remove_session
  WD_MENU_LOG="$BASE/menu" work _remove-menu client "$API_WIN"
  menu="$(cat "$BASE/menu")"
  assert_contains "$menu" "Remover um projeto"
  assert_contains "$menu" "old (pasta removida)"
  assert_contains "$menu" "run-shell \"work _remove-at 2 'client' '$API_WIN'\""
}

test_remove_menu_goes_back_with_esc_and_closes_with_q() {
  remove_session
  WD_MENU_LOG="$BASE/menu" work _remove-menu client "$API_WIN"
  menu="$(cat "$BASE/menu")"
  assert_contains "$menu" "← Voltar ao menu
Escape
run-shell \"work _menu 'client' '$API_WIN'\""
  assert_contains "$menu" "Fechar
q"
}

test_remove_from_the_menu_drops_the_chosen_project() {
  remove_session
  WD_MENU_LOG="$BASE/menu" work _remove-at 2 client "$API_WIN" >/dev/null 2>&1 || fail "work _remove-at exited with an error"
  assert_equal "$(tr '\n' ' ' < "$CONFIG/projects.conf")" "painel|~|work-panel api|~/api web|~/web " "projects.conf"
  menu="$(cat "$BASE/menu" 2>/dev/null)"
  assert_contains "$menu" "Remover um projeto" "the menu opens again"
  assert_not_contains "$menu" "old" "the removed project in the menu"
}

test_work_rm_is_an_alias_of_remove() {
  remove_session
  output="$(work rm api 2>&1)" || fail "work rm exited with an error: $output"
  assert_contains "$output" "api saiu do seu work"
  assert_equal "$(tr '\n' ' ' < "$CONFIG/projects.conf")" "painel|~|work-panel old|~/gone web|~/web " "projects.conf"
}
