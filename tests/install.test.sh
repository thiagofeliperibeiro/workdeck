test_installs_from_scratch() {
  install_workdeck || fail "install exited with an error"
  assert "work is on the PATH" test -x "$HOME/.local/bin/work"
  assert "the code copy exists" test -f "$CODE/lib/common.sh"
  assert "the 00-workdeck panel was installed" test -x "$CONFIG/panels/00-workdeck"
  assert "the 20-projetos panel was installed" test -x "$CONFIG/panels/20-projetos"
  assert "the manifest was written" test -f "$CONFIG/.install-manifest"
  assert_equal "$(count_blocks "$HOME/.tmux.conf")" 1 "blocks in tmux.conf"
  assert_equal "$(count_blocks "$(shell_rc_file)")" 1 "blocks in the shell file"
}

test_reinstall_does_not_duplicate() {
  install_workdeck >/dev/null || fail "first install"
  install_workdeck >/dev/null || fail "second install"
  assert_equal "$(count_blocks "$HOME/.tmux.conf")" 1 "blocks in tmux.conf"
  assert_equal "$(count_blocks "$(shell_rc_file)")" 1 "blocks in the shell file"
  assert_equal "$(grep -c '^block|' "$CONFIG/.install-manifest")" 2 "blocks in the manifest"
}

test_keeps_existing_content() {
  printf 'set -g history-limit 5000\n' > "$HOME/.tmux.conf"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert "the user's line is kept" grep -qx 'set -g history-limit 5000' "$HOME/.tmux.conf"
  assert "a copy of the original was saved" sh -c "ls '$CONFIG/.backups/' | grep -q tmux.conf"
}

test_does_not_replace_someone_elses_work() {
  mkdir -p "$HOME/.local/bin"
  printf '#!/bin/sh\necho mine\n' > "$HOME/.local/bin/work"
  output="$(install_workdeck 2>&1)" || fail "install exited with an error"
  assert_equal "$(cat "$HOME/.local/bin/work")" "$(printf '#!/bin/sh\necho mine')" "the user's work"
  assert_contains "$output" "já existe um work que não é do workdeck"
}

test_dry_run_writes_nothing() {
  rm -f "$CONFIG/settings.conf"
  echo nord > "$CONFIG/theme"
  install_workdeck --dry-run >/dev/null || fail "dry run exited with an error"
  assert "did not create tmux.conf" test ! -e "$HOME/.tmux.conf"
  assert "did not create settings.conf" test ! -e "$CONFIG/settings.conf"
  assert "did not migrate the old theme file" test -e "$CONFIG/theme"
  assert "did not install work" test ! -e "$HOME/.local/bin/work"
}

test_migrates_legacy_config() {
  rm -f "$CONFIG/settings.conf"
  echo nord > "$CONFIG/tema"
  echo nenhuma > "$CONFIG/integracoes"
  echo nao > "$CONFIG/zsh"
  echo AVISO=0 > "$CONFIG/atualizacao.conf"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_equal "$(saved_setting THEME)" nord "THEME"
  assert_equal "$(saved_setting INTEGRATIONS)" none "INTEGRATIONS"
  assert_equal "$(saved_setting ZSH)" no "ZSH"
  assert_equal "$(saved_setting NOTIFY)" 0 "NOTIFY"
  for old in tema integracoes atualizacao.conf theme integrations zsh update.conf; do
    assert "$old was removed" test ! -e "$CONFIG/$old"
  done
}

test_fresh_install_seeds_the_active_pane_example() {
  rm -f "$CONFIG/settings.conf"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_contains "$(cat "$CONFIG/settings.conf")" '#ACTIVE_PANE="line"' "the commented example"
  assert_equal "$(saved_setting THEME)" catppuccin-mocha "THEME"
  assert_equal "$(head -c 1 "$CONFIG/settings.conf")" "#" "the file starts with the explanatory header"
  theme_line="$(grep -n '^THEME=' "$CONFIG/settings.conf" | cut -d: -f1)"
  example_line="$(grep -n '^#ACTIVE_PANE=' "$CONFIG/settings.conf" | cut -d: -f1)"
  assert "the saved keys come before the commented examples" test "$theme_line" -lt "$example_line"
}

test_migrated_install_keeps_the_header_first() {
  rm -f "$CONFIG/settings.conf"
  echo nord > "$CONFIG/theme"
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_contains "$(head -n 1 "$CONFIG/settings.conf")" "Configurações do workdeck" "first line of a migrated file"
}

test_migrated_install_gets_the_active_pane_example_once() {
  rm -f "$CONFIG/settings.conf"
  echo nord > "$CONFIG/theme"
  install_workdeck >/dev/null || fail "install exited with an error"
  install_workdeck >/dev/null || fail "reinstall exited with an error"
  assert_equal "$(saved_setting THEME)" nord "THEME"
  assert_equal "$(grep -c '^#ACTIVE_PANE=' "$CONFIG/settings.conf")" 1 "copies of the example"
}

snippet_loads_oh_my_zsh() {
  local settings_lines="$1" prelude="${2:-:}"
  mkdir -p "$HOME/.oh-my-zsh" "$CONFIG"
  echo 'OMZ_LOADED=1' > "$HOME/.oh-my-zsh/oh-my-zsh.sh"
  printf '%b' "$settings_lines" > "$CONFIG/settings.conf"
  zsh -f -c "$prelude; . '$REPO/config/shell-snippet.sh'; echo \${OMZ_LOADED:-no}"
}

test_snippet_enables_zsh_only_on_the_exact_line() {
  command -v zsh >/dev/null || { echo "skipped: no zsh here"; return 0; }
  assert_equal "$(snippet_loads_oh_my_zsh 'ZSH="yes"\n')" 1 'ZSH="yes"'
  assert_equal "$(snippet_loads_oh_my_zsh 'ZSH=yes\n')" no 'ZSH=yes without quotes'
  assert_equal "$(snippet_loads_oh_my_zsh '#ZSH="yes"\n')" no 'commented line'
  assert_equal "$(snippet_loads_oh_my_zsh 'ZSH="no"\nZSH="yes"\n')" no 'the first line wins'
  assert_equal "$(snippet_loads_oh_my_zsh 'ZSH="yes\nZSH="yes"\n')" 1 'an unterminated first line is skipped, as setting_get does'
  assert_equal "$(snippet_loads_oh_my_zsh 'ZSH="yes"\n' "alias grep='grep -n'")" 1 'a grep alias in the .zshrc'
  assert_equal "$(snippet_loads_oh_my_zsh 'ZSH="yes"\n' "grep() { return 1; }")" 1 'a grep function in the .zshrc'
}

test_update_desligar_and_ligar_toggle_notify() {
  install_workdeck >/dev/null || fail "install exited with an error"
  work update --desligar >/dev/null || fail "update --desligar exited with an error"
  assert_equal "$(saved_setting NOTIFY)" 0 "NOTIFY after --desligar"
  work update --ligar >/dev/null || fail "update --ligar exited with an error"
  assert "NOTIFY is gone after --ligar" lacks_saved_setting NOTIFY
}

test_agent_set_saves_agent_cmd_in_settings() {
  install_workdeck >/dev/null || fail "install exited with an error"
  bash "$CODE/bin/workdeck-agent" --set "sh -x" >/dev/null || fail "--set exited with an error"
  assert_equal "$(saved_setting AGENT_CMD)" "sh -x" "AGENT_CMD"
  assert "no agent.conf was created" test ! -e "$CONFIG/agent.conf"
}

test_agent_cmd_is_read_without_sourcing() {
  install_workdeck >/dev/null || fail "install exited with an error"
  printf 'touch "%s/pwned"\nAGENT_CMD="not-a-real-agent-xyz"\n' "$TEST_TMP" >> "$CONFIG/settings.conf"
  output="$(bash "$CODE/bin/workdeck-agent" --check 2>&1)" && fail "--check should fail for an agent that is not on the PATH"
  assert_contains "$output" "'not-a-real-agent-xyz' não está no PATH"
  assert "the settings file was not executed" test ! -e "$TEST_TMP/pwned"
}
