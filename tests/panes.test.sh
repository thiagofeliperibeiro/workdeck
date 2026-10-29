start_tmux_with_active_pane() {
  install_workdeck >/dev/null || fail "install exited with an error"
  [ -z "${1:-}" ] || save_setting ACTIVE_PANE "$1"
  tmux -f "$HOME/.tmux.conf" new-session -d -s p || fail "tmux did not start with the installed config"
}

border_status() { tmux show -gwv pane-border-status; }

border_status_is() { [ "$(border_status)" = "$1" ]; }

test_active_pane_line_turns_the_top_line_on() {
  start_tmux_with_active_pane line
  wait_for border_status_is top || fail "the top line was not turned on"
  assert_equal "$(tmux show -gwv pane-border-format)" "" "pane-border-format"
  assert_equal "$(tmux show -gv pane-border-indicators)" off "pane-border-indicators"
  assert_equal "$(tmux show -gwv pane-active-border-style)" "fg=#cba6f7" "active border colour"
  assert_equal "$(tmux show -gwv pane-border-style)" "fg=#6c7086" "inactive border colour"
}

test_active_pane_is_off_by_default() {
  start_tmux_with_active_pane
  work _settings
  assert_equal "$(border_status)" off "pane-border-status"
  assert_equal "$(tmux show -gv pane-border-indicators)" colour "pane-border-indicators"
}

test_none_after_line_turns_it_off() {
  start_tmux_with_active_pane line
  wait_for border_status_is top || fail "the top line was not turned on"
  save_setting ACTIVE_PANE none
  work _settings
  assert_equal "$(border_status)" off "pane-border-status"
  assert_equal "$(tmux show -gv pane-border-indicators)" colour "pane-border-indicators"
  assert_equal "$(tmux show -gqv @wd_active_pane)" "" "the marker"
  assert "the empty pane-border-format is undone" test -n "$(tmux show -gwv pane-border-format)"
}

test_none_without_line_keeps_the_users_own_setting() {
  printf 'set -g pane-border-status bottom\n' > "$HOME/.tmux.conf"
  start_tmux_with_active_pane
  work _settings
  assert_equal "$(border_status)" bottom "the user's pane-border-status"
}

test_invalid_active_pane_warns_and_acts_like_none() {
  start_tmux_with_active_pane xyz
  output="$(work _settings 2>&1)"
  assert_contains "$output" "inválido" "the warning"
  assert_contains "$output" 'ACTIVE_PANE="xyz"' "the warning names the value"
  assert_equal "$(border_status)" off "pane-border-status"
}

test_settings_command_without_a_server_is_silent() {
  install_workdeck >/dev/null || fail "install exited with an error"
  tmux kill-server >/dev/null 2>&1 || true
  output="$(work _settings 2>&1)" || fail "work _settings failed without a server"
  assert_equal "$output" "" "output without a server"
}

test_settings_command_without_theme_colours_does_not_fail() {
  install_workdeck >/dev/null || fail "install exited with an error"
  save_setting ACTIVE_PANE line
  tmux -f /dev/null new-session -d -s bare || fail "tmux did not start"
  before="$(tmux show -gwv pane-active-border-style)"
  output="$(work _settings 2>&1)" || fail "work _settings failed without the theme options"
  assert_equal "$output" "" "output without the theme options"
  assert_equal "$(tmux show -gwv pane-active-border-style)" "$before" "border colour left alone"
  assert_equal "$(border_status)" top "pane-border-status"
}

test_run_shell_line_comes_after_the_theme() {
  install_workdeck >/dev/null || fail "install exited with an error"
  theme_end="$(grep -n '^setw -g window-active-style' "$HOME/.tmux.conf" | tail -1 | cut -d: -f1)"
  run_shell="$(grep -n 'work _settings' "$HOME/.tmux.conf" | tail -1 | cut -d: -f1)"
  block_end="$(grep -n '^# <<< workdeck <<<$' "$HOME/.tmux.conf" | tail -1 | cut -d: -f1)"
  assert "the run-shell line exists" test -n "$run_shell"
  assert "it comes after the theme" test "$run_shell" -gt "$theme_end"
  assert "it comes before the end marker" test "$run_shell" -lt "$block_end"
}
