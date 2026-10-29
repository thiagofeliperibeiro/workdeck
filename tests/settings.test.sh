load_settings_lib() {
  . "$REPO/lib/common.sh"
  rm -f "$WORKDECK_SETTINGS"
}

write_settings() {
  mkdir -p "$(dirname "$WORKDECK_SETTINGS")"
  printf '%b' "$1" > "$WORKDECK_SETTINGS"
}

test_get_returns_the_default_when_the_file_or_key_is_missing() {
  load_settings_lib
  assert_equal "$(setting_get THEME nord)" nord "default without a file"
  assert_equal "$(setting_get THEME)" "" "empty default"
  setting_set ZSH no
  assert_equal "$(setting_get THEME nord)" nord "default without the key"
}

test_set_creates_the_file_and_get_reads_it_back() {
  load_settings_lib
  setting_set THEME nord
  assert_equal "$(cat "$WORKDECK_SETTINGS")" 'THEME="nord"' "file content"
  assert_equal "$(setting_get THEME)" nord "value"
}

test_set_replaces_in_place_and_keeps_everything_else() {
  load_settings_lib
  write_settings '# nota\nTHEME="a"\nZSH="no"\n'
  setting_set THEME b
  assert_equal "$(cat "$WORKDECK_SETTINGS")" "$(printf '# nota\nTHEME="b"\nZSH="no"')" "file content"
}

test_first_occurrence_wins_and_set_touches_only_it() {
  load_settings_lib
  write_settings 'THEME="a"\nTHEME="z"\n'
  assert_equal "$(setting_get THEME)" a "first occurrence"
  setting_set THEME b
  assert_equal "$(cat "$WORKDECK_SETTINGS")" "$(printf 'THEME="b"\nTHEME="z"')" "file content"
}

test_commented_and_malformed_lines_do_not_count() {
  load_settings_lib
  write_settings '#ZSH="yes"\nZSH=yes\nZSH = "yes"\n'
  if setting_has ZSH; then fail "a commented or malformed line counted as the key"; fi
  setting_set ZSH no
  assert_equal "$(cat "$WORKDECK_SETTINGS")" "$(printf '#ZSH="yes"\nZSH=yes\nZSH = "yes"\nZSH="no"')" "file content"
}

test_set_appends_after_a_file_without_trailing_newline() {
  load_settings_lib
  write_settings 'THEME="a"'
  setting_set ZSH no
  assert_equal "$(cat "$WORKDECK_SETTINGS")" "$(printf 'THEME="a"\nZSH="no"')" "file content"
}

test_values_with_quotes_backslashes_and_spaces_round_trip() {
  load_settings_lib
  value="claude --append-system-prompt \"a b\" \\c end\\"
  setting_set AGENT_CMD "$value"
  assert_equal "$(setting_get AGENT_CMD)" "$value" "round trip"
}

test_an_empty_value_is_a_value() {
  load_settings_lib
  setting_set INTEGRATIONS ""
  assert "an empty value counts as set" setting_has INTEGRATIONS
  assert_equal "$(setting_get INTEGRATIONS fallback)" "" "empty value instead of the default"
}

test_set_refuses_a_value_with_a_newline() {
  load_settings_lib
  write_settings 'THEME="a"\n'
  before="$(cksum < "$WORKDECK_SETTINGS")"
  if setting_set THEME "$(printf 'a\nb')"; then fail "a value with a newline was accepted"; fi
  assert_equal "$(cksum < "$WORKDECK_SETTINGS")" "$before" "file after the refusal"
}

test_unset_removes_only_that_line() {
  load_settings_lib
  write_settings '# nota\nTHEME="a"\nZSH="no"\n'
  setting_unset THEME
  assert_equal "$(cat "$WORKDECK_SETTINGS")" "$(printf '# nota\nZSH="no"')" "file content"
  setting_unset THEME
  assert_equal "$(cat "$WORKDECK_SETTINGS")" "$(printf '# nota\nZSH="no"')" "unset of a missing key"
}

seed_old_choice_files() {
  mkdir -p "$WORKDECK_CONFIG"
  echo warp > "$WORKDECK_CONFIG/terminal"
  echo nord > "$WORKDECK_CONFIG/theme"
  echo no > "$WORKDECK_CONFIG/visual"
  echo none > "$WORKDECK_CONFIG/integrations"
  echo yes > "$WORKDECK_CONFIG/zsh"
  echo 'AGENT_CMD="claude --x"' > "$WORKDECK_CONFIG/agent.conf"
  echo NOTIFY=0 > "$WORKDECK_CONFIG/update.conf"
}

test_migrates_every_choice_file() {
  load_settings_lib
  seed_old_choice_files
  migrate_choice_files
  assert_equal "$(setting_get TERMINAL)" warp "TERMINAL"
  assert_equal "$(setting_get THEME)" nord "THEME"
  assert_equal "$(setting_get VISUAL)" no "VISUAL"
  assert_equal "$(setting_get INTEGRATIONS)" none "INTEGRATIONS"
  assert_equal "$(setting_get ZSH)" yes "ZSH"
  assert_equal "$(setting_get AGENT_CMD)" "claude --x" "AGENT_CMD"
  assert_equal "$(setting_get NOTIFY)" 0 "NOTIFY"
  for old in terminal theme visual integrations zsh agent.conf update.conf; do
    assert "$old was removed" test ! -e "$WORKDECK_CONFIG/$old"
  done
}

test_empty_choice_file_is_removed_without_creating_a_key() {
  load_settings_lib
  mkdir -p "$WORKDECK_CONFIG"
  : > "$WORKDECK_CONFIG/terminal"
  migrate_choice_files
  assert "the empty file was removed" test ! -e "$WORKDECK_CONFIG/terminal"
  if setting_has TERMINAL; then fail "an empty file created a key"; fi
}

test_migration_does_not_overwrite_an_existing_key() {
  load_settings_lib
  setting_set THEME nord
  echo catppuccin-mocha > "$WORKDECK_CONFIG/theme"
  migrate_choice_files
  assert_equal "$(setting_get THEME)" nord "THEME"
  assert "the old file was removed" test ! -e "$WORKDECK_CONFIG/theme"
}

test_migration_is_idempotent() {
  load_settings_lib
  seed_old_choice_files
  migrate_choice_files
  assert_equal "$(setting_get THEME)" nord "the first run migrated"
  before="$(cksum < "$WORKDECK_SETTINGS")"
  migrate_choice_files
  assert_equal "$(cksum < "$WORKDECK_SETTINGS")" "$before" "settings.conf after the second run"
}

test_template_is_added_once() {
  load_settings_lib
  settings_ensure_template
  assert_contains "$(cat "$WORKDECK_SETTINGS")" '#ACTIVE_PANE="line"' "the commented example"
  before="$(cksum < "$WORKDECK_SETTINGS")"
  settings_ensure_template
  assert_equal "$(cksum < "$WORKDECK_SETTINGS")" "$before" "file after the second call"
}

test_template_keeps_the_users_edits() {
  load_settings_lib
  write_settings 'THEME="a"\n'
  settings_ensure_template
  assert_contains "$(cat "$WORKDECK_SETTINGS")" '#ACTIVE_PANE="line"' "the example is added next to other keys"
  write_settings 'ACTIVE_PANE="line"\n'
  settings_ensure_template
  assert_equal "$(cat "$WORKDECK_SETTINGS")" 'ACTIVE_PANE="line"' "an active key is left alone"
  write_settings '#ACTIVE_PANE="none"\n'
  settings_ensure_template
  assert_equal "$(cat "$WORKDECK_SETTINGS")" '#ACTIVE_PANE="none"' "a commented key is left alone"
}

test_set_and_unset_write_through_a_symlinked_file() {
  load_settings_lib
  mkdir -p "$TEST_TMP/dotfiles" "$WORKDECK_CONFIG"
  printf 'THEME="a"\nZSH="no"\n' > "$TEST_TMP/dotfiles/settings.conf"
  chmod 600 "$TEST_TMP/dotfiles/settings.conf"
  ln -s "$TEST_TMP/dotfiles/settings.conf" "$WORKDECK_SETTINGS"
  setting_set THEME b
  setting_unset ZSH
  assert "settings.conf is still a symlink" test -L "$WORKDECK_SETTINGS"
  assert_equal "$(cat "$TEST_TMP/dotfiles/settings.conf")" 'THEME="b"' "the file the link points to"
  assert "the mode of the file is kept" test -n "$(find "$TEST_TMP/dotfiles/settings.conf" -perm 600)"
  assert "no temporary file is left behind" test ! -e "$TEST_TMP/dotfiles/settings.conf.tmp"
}

test_a_non_utf8_comment_does_not_hide_the_keys() {
  load_settings_lib
  mkdir -p "$WORKDECK_CONFIG"
  printf '# caf\351\nTHEME="nord"\n' > "$WORKDECK_SETTINGS"
  assert_equal "$(setting_get THEME)" nord "THEME next to a Latin-1 comment"
  assert "the key is found" setting_has THEME
}
