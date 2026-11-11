message_keys() {
  grep -oE '^msg_[a-z0-9_]+=' "$REPO/lang/$1.sh" | sort
}

english_system() {
  unset WORKDECK_LANG LC_ALL LC_MESSAGES
  export LANG=en_US.UTF-8
}

test_both_languages_have_the_same_messages() {
  assert_equal "$(message_keys en)" "$(message_keys pt-BR)" "message keys in en.sh and pt-BR.sh"
}

test_fresh_install_follows_the_system_language() {
  english_system
  rm -f "$CONFIG/settings.conf"
  output="$(install_workdeck 2>&1)" || fail "install exited with an error"
  assert_contains "$output" "[1/7] dependencies"
  assert_not_contains "$output" "No such file"
  assert_contains "$(grep '^LANGUAGE=' "$CONFIG/settings.conf")" 'LANGUAGE="en"' "the saved language"
  assert_contains "$(head -1 "$CONFIG/settings.conf")" "# workdeck settings." "the settings header"
  assert_contains "$(work nada 2>&1)" "unknown command 'work nada'"
}

test_lang_option_wins_over_the_system() {
  english_system
  output="$(install_workdeck --lang pt-BR 2>&1)" || fail "install exited with an error"
  assert_contains "$output" "[1/7] dependências"
  assert_contains "$(grep '^LANGUAGE=' "$CONFIG/settings.conf")" 'LANGUAGE="pt-BR"' "the saved language"
  assert_contains "$(work nada 2>&1)" "não conheço 'work nada'"
}

test_existing_install_keeps_portuguese() {
  english_system
  install_workdeck --lang en >/dev/null || fail "first install"
  setting_line="$(grep -v '^LANGUAGE=' "$CONFIG/settings.conf")"
  printf '%s\n' "$setting_line" > "$CONFIG/settings.conf"
  output="$(install_workdeck 2>&1)" || fail "second install"
  assert_contains "$output" "[1/7] dependências"
  assert_contains "$(grep '^LANGUAGE=' "$CONFIG/settings.conf")" 'LANGUAGE="pt-BR"' "the saved language"
}

test_saved_language_is_kept_on_reinstall() {
  unset WORKDECK_LANG LC_ALL LC_MESSAGES
  export LANG=pt_BR.UTF-8
  install_workdeck --lang en >/dev/null || fail "first install"
  install_workdeck >/dev/null || fail "second install"
  assert_contains "$(work --help 2>&1)" "The commands are:"
  assert_equal "$(grep -c '^LANGUAGE=' "$CONFIG/settings.conf")" 1 "LANGUAGE lines"
}

test_unknown_language_fails() {
  output="$(install_workdeck --lang fr 2>&1)" && fail "install accepted an unknown language"
  assert_contains "$output" "idioma 'fr' não existe"
}

test_help_comes_from_the_language_file() {
  english_system
  assert_contains "$(bash "$REPO/install.sh" --help)" "--lang pt-BR"
  assert_contains "$(bash "$REPO/install.sh" --lang pt-BR --help)" "escolhe o idioma"
}

english_install() {
  unset WORKDECK_LANG LC_ALL LC_MESSAGES
  export LANG=pt_BR.UTF-8
  install_workdeck --lang en >/dev/null || fail "install exited with an error"
}

test_english_panel_status_bar_and_window() {
  english_install
  assert "the tmux block has the English key message" grep -q 'key not used in workdeck' "$HOME/.tmux.conf"
  assert_not_contains "$(cat "$HOME/.tmux.conf")" "{{msg:" "markers left in tmux.conf"
  mkdir -p "$HOME/api"
  work add "$HOME/api" >/dev/null
  assert_equal "$(head -1 "$CONFIG/projects.conf")" "panel|~|work-panel" "the panel line"
  output="$("$CODE/bin/work-panel" --once | sed 's/\x1b\[[0-9;]*m//g')"
  assert_contains "$output" "Projects"
  assert_contains "$output" "Ctrl+b h opens the menu"
}

test_reinstall_renames_the_panel_window_line() {
  install_workdeck --lang pt-BR >/dev/null || fail "first install"
  printf 'painel|~|work-panel\napi|~/api\n' > "$CONFIG/projects.conf"
  install_workdeck --lang en >/dev/null || fail "second install"
  assert_equal "$(cat "$CONFIG/projects.conf")" "panel|~|work-panel
api|~/api" "projects.conf"
}

test_update_notes_follow_the_language() {
  english_install
  printf '\n## v9.0.0\n\n### Português\n\n- nota em português\n\n### English\n\n- English note\n' >> "$REPO/CHANGELOG.md"
  git -C "$REPO" -c user.name=test -c user.email=test@example.com commit -qam notes
  git -C "$REPO" tag v9.0.0
  output="$(work update 2>&1 </dev/null)"
  assert_contains "$output" "What changed"
  assert_contains "$output" "English note"
  assert_not_contains "$output" "nota em português"
  sed -i.bak 's/^LANGUAGE=.*/LANGUAGE="pt-BR"/' "$CONFIG/settings.conf"
  output="$(work update 2>&1 </dev/null)"
  assert_contains "$output" "O que mudou"
  assert_contains "$output" "nota em português"
  assert_not_contains "$output" "English note"
}
