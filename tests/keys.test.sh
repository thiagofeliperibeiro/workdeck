start_tmux_with_installed_config() {
  install_workdeck >/dev/null || fail "install exited with an error"
  tmux -f "$HOME/.tmux.conf" new-session -d -s keys || fail "tmux did not start with the installed config"
}

test_option_delete_reaches_the_pane_as_esc_del() {
  start_tmux_with_installed_config
  assert_contains "$(tmux list-keys -T root M-BSpace 2>&1)" "send-keys -H 1b 7f" "Option+Delete binding"
}

test_extended_keys_stay_on_for_shift_enter() {
  start_tmux_with_installed_config
  assert_equal "$(tmux show -gv extended-keys)" on "extended-keys"
}

test_option_left_and_right_stay_free_to_move_by_word() {
  start_tmux_with_installed_config
  assert_not_contains "$(tmux list-keys -T root)" "M-Left " "Option+Left binding"
  assert_not_contains "$(tmux list-keys -T root)" "M-Right " "Option+Right binding"
}

test_reloading_the_config_drops_an_old_option_left_and_right_binding() {
  start_tmux_with_installed_config
  tmux bind -n M-Left select-pane -L
  tmux bind -n M-Right select-pane -R
  tmux source-file "$HOME/.tmux.conf" || fail "tmux could not reload the installed config"
  assert_not_contains "$(tmux list-keys -T root)" "M-Left " "Option+Left binding after reload"
  assert_not_contains "$(tmux list-keys -T root)" "M-Right " "Option+Right binding after reload"
}

test_kitty_sends_shift_enter_in_the_extended_format() {
  assert_contains "$(cat "$REPO/terminals/kitty.conf")" 'send_text all \x1b[13;2u' "Shift+Enter mapping"
}

test_kitty_sends_shift_enter_only_while_tmux_is_focused() {
  assert_contains "$(cat "$REPO/terminals/kitty.conf")" 'map --when-focus-on cmdline:tmux shift+enter' "Shift+Enter scope"
}

test_dragging_a_project_lights_it_up_until_it_is_dropped() {
  local end
  start_tmux_with_installed_config
  assert_contains "$(tmux list-keys -T root MouseDrag1Status 2>&1)" "set-option -g @wd_drag 1" "drag binding"
  assert_not_contains "$(tmux list-keys -T root MouseDrag1Status 2>&1)" "swap-window" "nothing moves before the drop"
  assert_contains "$(tmux list-keys -T root MouseDragEnd1Status 2>&1)" "work _drop" "the drop swaps the projects"
  for end in MouseDragEnd1Status MouseDragEnd1StatusDefault MouseDragEnd1StatusLeft MouseDragEnd1StatusRight MouseDragEnd1Pane; do
    assert_contains "$(tmux list-keys -T root "$end" 2>&1)" "set-option -gu @wd_drag" "$end clears the highlight"
  done
  assert_contains "$(tmux list-keys -T root MouseDragEnd1Pane 2>&1)" "send-keys -M" "the pane still gets the mouse"
  tmux set -g @wd_drag 1
  assert_contains "$(tmux display -p -t keys '#{E:window-status-current-format}')" "bg=" "held project while dragging"
  tmux set -gu @wd_drag
  assert_not_contains "$(tmux display -p -t keys '#{E:window-status-current-format}')" "bg=" "project after the drop"
}

test_the_status_bar_has_a_second_line_for_usage_and_the_clock() {
  start_tmux_with_installed_config
  assert_equal "$(tmux show -gv status)" 2 "status lines"
  assert_equal "$(tmux show -gv status-right)" "" "status-right on the first line"
  assert_contains "$(tmux show -gv 'status-format[1]')" "work _usage" "the second line"
  assert_contains "$(tmux show -gv 'status-format[1]')" "%H:%M" "the clock on the second line"
}
