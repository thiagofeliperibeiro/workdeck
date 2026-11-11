usage_lib() { . "$REPO/lib/common.sh"; . "$REPO/lib/json.sh"; . "$REPO/lib/usage.sh"; }

claude_input() {
  local now
  now="$(date +%s)"
  printf '{"model":{"id":"x"},"rate_limits": {"five_hour": {"used_percentage": 42.6, "resets_at": %s}, "seven_day": {"used_percentage": 12, "resets_at": %s}}}' \
    "$((now + 3600))" "$((now + 86400))"
}

codex_log() {
  local dir="$HOME/.codex/sessions/2026/11/11"
  mkdir -p "$dir"
  printf '%s\n' "$@" > "$dir/rollout-1.jsonl"
}

claude_settings() { cat "$HOME/.claude/settings.json"; }

test_json_set_and_delete_keep_the_rest_of_the_file() {
  usage_lib
  local file="$HOME/s.json"
  printf '{\n  "theme": "dark",\n  "env": {\n    "A": "}"\n  }\n}\n' > "$file"
  json_set "$file" statusLine '{"type": "command", "command": "x"}' || fail "set"
  assert_equal "$(json_get "$file" statusLine)" '{"type": "command", "command": "x"}' "value after set"
  assert_equal "$(json_get "$file" env | tr -d ' \n')" '{"A":"}"}' "a nested brace inside a string"
  json_delete "$file" statusLine || fail "delete"
  assert_equal "$(cat "$file")" "$(printf '{\n  "theme": "dark",\n  "env": {\n    "A": "}"\n  }\n}')" "file after delete"
}

test_json_refuses_a_file_that_is_not_an_object() {
  usage_lib
  local file="$HOME/s.json"
  printf 'not json\n' > "$file"
  json_set "$file" statusLine '{}' && fail "set accepted invalid JSON"
  assert_equal "$(cat "$file")" "not json" "file left alone"
  printf '{"a": 1' > "$file"
  json_get "$file" a && fail "get accepted an unclosed object"
  return 0
}

test_json_string_field_reads_the_key_not_a_value() {
  usage_lib
  assert_equal "$(json_string_field '{"type":"command","command":"bash -c \"echo hi\""}' command)" 'bash -c "echo hi"' "command"
}

test_statusline_saves_the_claude_limits() {
  usage_lib
  claude_input | bash "$REPO/bin/workdeck-statusline" || fail "statusline exited with an error"
  assert_contains "$(cat "$USAGE_DIR/claude")" "5h 42.6 " "five-hour window"
  assert_contains "$(cat "$USAGE_DIR/claude")" "7d 12 " "weekly window"
}

test_statusline_keeps_the_last_limits_when_none_come() {
  usage_lib
  claude_input | bash "$REPO/bin/workdeck-statusline" >/dev/null
  printf '{"model":{"id":"x"}}' | bash "$REPO/bin/workdeck-statusline" >/dev/null
  assert_contains "$(cat "$USAGE_DIR/claude")" "5h 42.6 " "earlier limits"
}

test_statusline_runs_the_previous_status_line() {
  usage_lib
  mkdir -p "$(dirname "$CLAUDE_PREVIOUS_STATUSLINE")"
  printf '{"type": "command", "command": "cat > \\"%s/seen\\"; echo mine"}\n' "$HOME" > "$CLAUDE_PREVIOUS_STATUSLINE"
  output="$(claude_input | bash "$REPO/bin/workdeck-statusline")"
  assert_equal "$output" mine "output of the previous status line"
  assert_contains "$(cat "$HOME/seen")" '"rate_limits"' "the previous status line got the same input"
}

test_codex_limits_come_from_the_session_log() {
  usage_lib
  local now
  now="$(date +%s)"
  codex_log '{"type":"event_msg","payload":{"type":"token_count","info":null,"rate_limits":null}}' \
    "{\"type\":\"event_msg\",\"payload\":{\"type\":\"token_count\",\"info\":{\"a\":{\"b\":1}},\"rate_limits\":{\"limit_id\":\"codex\",\"primary\":{\"used_percent\":12.0,\"window_minutes\":300,\"resets_at\":$((now + 100))},\"secondary\":{\"used_percent\":55.5,\"window_minutes\":10080,\"resets_in_seconds\":5000},\"credits\":null}}}"
  output="$(usage_codex)"
  assert_contains "$output" "5h 12.0 $((now + 100))" "primary window"
  assert_contains "$output" "7d 55.5 " "secondary window with resets_in_seconds"
  assert "the answer was cached" test -f "$USAGE_DIR/codex"
}

test_render_draws_bars_and_drops_a_window_that_reset() {
  usage_lib
  output="$(printf '5h 42.6 200\n7d 93 50\n2d 100 300\n' | usage_render claude 100 A D M)"
  assert_contains "$output" "claude" "agent name"
  assert_contains "$output" "5h #[fg=A]▰▰#[fg=D]▱▱▱ #[fg=M]43%" "five-hour bar"
  assert_not_contains "$output" "7d" "a window whose reset passed"
  assert_contains "$output" "#[fg=red]▰▰▰▰▰" "a full window is red"
  assert_equal "$(printf '7d 93 50\n' | usage_render claude 100 A D M)" "" "nothing left to show"
}

test_status_shows_the_agent_with_the_newest_data() {
  usage_lib
  claude_input | bash "$REPO/bin/workdeck-statusline" >/dev/null
  assert_equal "$(usage_pick_agent "")" claude "only Claude has data"
  assert_contains "$(usage_status "")" "claude" "status segment"
}

test_install_points_claude_at_workdeck_and_uninstall_reverts() {
  mkdir -p "$HOME/.claude"
  printf '{\n  "theme": "dark"\n}\n' > "$HOME/.claude/settings.json"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_contains "$(claude_settings)" "\"command\": \"$CODE/bin/workdeck-statusline\"" "statusLine set"
  assert_contains "$(claude_settings)" '"theme": "dark"' "other settings kept"
  install_workdeck >/dev/null || fail "second install"
  assert_equal "$(grep -c statusLine "$HOME/.claude/settings.json")" 1 "statusLine once"
  bash "$CODE/uninstall.sh" >/dev/null || fail "uninstall exited with an error"
  assert_equal "$(claude_settings)" "$(printf '{\n  "theme": "dark"\n}')" "settings as before"
}

test_install_keeps_the_users_status_line_and_uninstall_brings_it_back() {
  mkdir -p "$HOME/.claude"
  printf '{"statusLine":{"type":"command","command":"echo mine"}}\n' > "$HOME/.claude/settings.json"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_contains "$(claude_settings)" "workdeck-statusline" "statusLine set"
  install_workdeck >/dev/null || fail "second install"
  assert_contains "$(cat "$CONFIG/claude-statusline.json")" "echo mine" "the user's status line is kept after an update"
  output="$(claude_input | bash "$CODE/bin/workdeck-statusline")"
  assert_equal "$output" mine "the user's status line still shows"
  bash "$CODE/uninstall.sh" >/dev/null || fail "uninstall exited with an error"
  assert_equal "$(claude_settings)" '{"statusLine":{"type":"command","command":"echo mine"}}' "settings as before"
}

test_install_creates_claude_settings_only_for_claude_users() {
  install_workdeck >/dev/null || fail "install without Claude"
  assert "no Claude settings without Claude" test ! -e "$HOME/.claude/settings.json"
  mkdir -p "$HOME/.claude"
  install_workdeck >/dev/null || fail "install with Claude"
  assert_contains "$(claude_settings)" "workdeck-statusline" "statusLine set"
  bash "$CODE/uninstall.sh" >/dev/null || fail "uninstall exited with an error"
  assert "the file created by the install is gone" test ! -e "$HOME/.claude/settings.json"
}

test_install_leaves_invalid_claude_settings_alone() {
  mkdir -p "$HOME/.claude"
  printf '{ broken\n' > "$HOME/.claude/settings.json"
  output="$(install_workdeck 2>&1)" || fail "install exited with an error"
  assert_equal "$(claude_settings)" "{ broken" "file left alone"
  assert_contains "$output" "não é um JSON válido"
}
