fake_claude() {
  printf '#!/bin/sh\necho "claude-args:[$*]"\n' > "$BASE/bin/claude"
  chmod +x "$BASE/bin/claude"
}

snippet_claude() {
  env -i HOME="$HOME" PATH="$PATH" XDG_CONFIG_HOME="$HOME/.config" ${2:+TMUX=x} bash -c ". '$REPO/config/shell-snippet.sh'; claude $1"
}

claude_settings() { cat "$HOME/.claude/settings.json"; }

test_bare_claude_in_tmux_opens_the_diff_panel() {
  fake_claude
  assert_equal "$(snippet_claude "" tmux)" "claude-args:[/diff]" "bare claude in tmux"
  assert_equal "$(snippet_claude "--resume" tmux)" "claude-args:[--resume]" "claude with arguments"
  assert_equal "$(snippet_claude "")" "claude-args:[]" "claude outside tmux"
  echo 'CLAUDE_DIFF_PANEL="no"' >> "$CONFIG/settings.conf"
  assert_equal "$(snippet_claude "" tmux)" "claude-args:[]" "turned off in settings.conf"
}

test_an_alias_named_claude_wins_over_the_snippet() {
  fake_claude
  output="$(env -i HOME="$HOME" PATH="$PATH" TMUX=x bash -c "shopt -s expand_aliases; alias claude='echo mine'
. '$REPO/config/shell-snippet.sh'
claude")"
  assert_equal "$output" mine "the user's alias"
}

test_agent_pane_starts_claude_with_the_diff_panel() {
  fake_claude
  install_workdeck >/dev/null || fail "install exited with an error"
  echo 'AGENT_CMD="claude"' >> "$CONFIG/settings.conf"
  open_work_in_terminal work
  wait_for tmux has-session -t work || fail "the work session did not open"
  pane="$(tmux display -p -t work: '#{pane_id}')"
  work _agent "$pane" || fail "work _agent exited with an error"
  wait_for sh -c "tmux list-panes -a -F '#{pane_id}' | xargs -I{} tmux capture-pane -p -t {} | grep -qF 'claude-args:[/diff]'" ||
    fail "the agent pane did not start claude with /diff"
}

test_install_turns_on_the_fullscreen_renderer_and_uninstall_removes_it() {
  mkdir -p "$HOME/.claude"
  printf '{\n  "theme": "dark"\n}\n' > "$HOME/.claude/settings.json"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_contains "$(claude_settings)" '"tui": "fullscreen"' "tui set"
  bash "$CODE/uninstall.sh" >/dev/null || fail "uninstall exited with an error"
  assert_equal "$(claude_settings)" "$(printf '{\n  "theme": "dark"\n}')" "settings as before"
}

test_install_keeps_a_renderer_the_user_chose() {
  mkdir -p "$HOME/.claude"
  printf '{"tui": "default"}\n' > "$HOME/.claude/settings.json"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_contains "$(claude_settings)" '"tui": "default"' "the user's choice"
  assert_not_contains "$(claude_settings)" fullscreen "no fullscreen"
  bash "$CODE/uninstall.sh" >/dev/null || fail "uninstall exited with an error"
  assert_contains "$(claude_settings)" '"tui": "default"' "the user's choice after uninstall"
}

test_tui_default_after_install_survives_update_and_uninstall() {
  mkdir -p "$HOME/.claude"
  install_workdeck >/dev/null || fail "install exited with an error"
  sed -i.bak 's/"fullscreen"/"default"/' "$HOME/.claude/settings.json"
  install_workdeck >/dev/null || fail "update exited with an error"
  assert_contains "$(claude_settings)" '"tui": "default"' "the choice made with /tui"
  bash "$CODE/uninstall.sh" >/dev/null || fail "uninstall exited with an error"
  assert_contains "$(claude_settings)" '"tui": "default"' "the choice after uninstall"
}
