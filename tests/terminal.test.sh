kitty_conf() { echo "$HOME/.config/kitty/kitty.conf"; }

assert_kitty_shortcuts() {
  assert "the block was written to kitty.conf" grep -q '^# >>> workdeck >>>$' "$(kitty_conf)"
  if [ "$(uname -s)" = Darwin ]; then
    assert "the cmd shortcuts" grep -q '^map cmd+1 ' "$(kitty_conf)"
    assert "Cmd+Enter opens a pane in workdeck" grep -q '^map cmd+enter  *send_text all \\x02g$' "$(kitty_conf)"
    assert "Option as Alt" grep -q '^macos_option_as_alt' "$(kitty_conf)"
    return 0
  fi
  assert "no cmd shortcuts outside a Mac" test -z "$(grep '^map cmd\|^macos_' "$(kitty_conf)")"
  assert "the Ctrl+Shift shortcuts outside a Mac" grep -q '^map ctrl+shift+h ' "$(kitty_conf)"
  assert "Ctrl+Shift+Enter opens a pane in workdeck" grep -q '^map ctrl+shift+enter  *send_text all \\x02g$' "$(kitty_conf)"
}

test_terminal_kitty_installed_gets_the_block() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  assert "the block was written to kitty.conf" grep -q '^# >>> workdeck >>>$' "$(kitty_conf)"
  assert_equal "$(saved_setting TERMINAL)" kitty "saved choice"
}

test_terminal_kitty_missing_gets_the_block_and_downloads_nothing() {
  output="$(install_workdeck --terminal kitty 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "o kitty ainda não está instalado; os atalhos já estão no kitty.conf. Instale por https://sw.kovidgoyal.net/kitty/binary/"
  assert_kitty_shortcuts
  assert "nothing was downloaded" test ! -e "$HOME/Applications/kitty.app"
}

test_finish_asks_for_a_new_window_only_when_needed() {
  output="$(install_workdeck --terminal other 2>&1)" || fail "first install"
  assert_contains "$output" "abra uma janela nova"
  output="$(install_workdeck 2>&1)" || fail "second install"
  assert_not_contains "$output" "abra uma janela nova" "a reinstall that changed nothing"
  assert_not_contains "$output" "feche e abra" "a reinstall that changed nothing"
}

test_terminal_other_leaves_the_terminal_alone() {
  mkdir -p "$HOME/Applications/kitty.app"
  output="$(install_workdeck --terminal other 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "sem kitty"
  assert "no kitty.conf was created" test ! -e "$(kitty_conf)"
  assert "no visual choice was saved" lacks_saved_setting VISUAL
}

test_saved_terminal_applies_on_reinstall() {
  install_workdeck --terminal other >/dev/null || fail "the install exited with an error"
  mkdir -p "$HOME/Applications/kitty.app"
  output="$(install_workdeck 2>&1)" || fail "the reinstall exited with an error"
  assert_contains "$output" "sem kitty" "the saved choice"
  assert "kitty.conf still has no block" test ! -e "$(kitty_conf)"
}

test_requested_terminal_wins_over_saved() {
  save_setting TERMINAL other
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  assert_equal "$(saved_setting TERMINAL)" kitty "saved choice"
  assert "the block was written to kitty.conf" grep -q '^# >>> workdeck >>>$' "$(kitty_conf)"
}

test_terminal_without_a_question_uses_the_detected_one_and_saves_nothing() {
  export KITTY_WINDOW_ID=1
  output="$(install_workdeck 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "o kitty ainda não está instalado" "the detected terminal"
  assert "nothing was saved without a choice" lacks_saved_setting TERMINAL
}

test_install_shows_the_choices_and_how_to_change_them() {
  mkdir -p "$HOME/Applications/kitty.app"
  output="$(install_workdeck --terminal kitty --no-visual 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "terminal  kitty"
  assert_contains "$output" "./install.sh --terminal kitty ou --terminal other"
  assert_contains "$output" "visual    não"
  assert_contains "$output" "./install.sh --visual (tema e fonte) ou --no-visual"
  assert_not_contains "$output" "detectado, não salvo" "everything was saved"
}

test_choices_without_a_saved_answer_say_they_were_detected() {
  output="$(install_workdeck 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "(detectado, não salvo)"
}

test_terminal_other_does_not_show_the_visual_choice() {
  output="$(install_workdeck --terminal other 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "terminal  outro terminal"
  assert_not_contains "$output" "visual    "
}

test_unknown_terminal_fails() {
  if output="$(install_workdeck --terminal foo 2>&1)"; then fail "the install should fail"; fi
  assert_contains "$output" "terminal 'foo' não existe"
  assert_contains "$output" "Use kitty ou other"
}

test_visual_on_kitty_puts_theme_and_font_in_the_block() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty --visual >/dev/null || fail "the install exited with an error"
  assert "the theme colors" grep -q '^background ' "$(kitty_conf)"
  assert "the font" grep -q '^font_family .*JetBrains Mono' "$(kitty_conf)"
  assert "the padding" grep -q '^window_padding_width 8$' "$(kitty_conf)"
  assert_kitty_shortcuts
  assert_equal "$(saved_setting VISUAL)" yes "saved choice"
}

test_no_visual_on_kitty_writes_only_the_shortcuts() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty --no-visual >/dev/null || fail "the install exited with an error"
  assert_kitty_shortcuts
  assert "no colors" test -z "$(grep '^background \|^color0 ' "$(kitty_conf)")"
  assert "no font" test -z "$(grep '^font_family' "$(kitty_conf)")"
  assert "no padding" test -z "$(grep '^window_padding_width' "$(kitty_conf)")"
  assert_equal "$(saved_setting VISUAL)" no "saved choice"
}

test_saved_visual_applies_on_reinstall() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty --no-visual >/dev/null || fail "the install exited with an error"
  install_workdeck >/dev/null || fail "the reinstall exited with an error"
  assert "still no colors" test -z "$(grep '^background ' "$(kitty_conf)")"
}

test_requested_visual_replaces_the_block_without_duplicating() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty --visual >/dev/null || fail "the install exited with an error"
  install_workdeck --no-visual >/dev/null || fail "the reinstall exited with an error"
  assert_equal "$(count_blocks "$(kitty_conf)")" 1 "blocks in kitty.conf"
  assert "the colors are gone" test -z "$(grep '^background ' "$(kitty_conf)")"
}

test_visual_without_a_question_is_no_and_saves_nothing() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  assert_kitty_shortcuts
  assert "no colors" test -z "$(grep '^background ' "$(kitty_conf)")"
  assert "nothing was saved without a choice" lacks_saved_setting VISUAL
}

test_update_keeps_the_kitty_look_of_an_older_install() {
  mkdir -p "$HOME/Applications/kitty.app" "$(dirname "$(kitty_conf)")"
  printf '%s\n' '# >>> workdeck >>>' 'map cmd+1 send_text all \x021' 'font_family        JetBrains Mono' 'background #1e1e2e' '# <<< workdeck <<<' > "$(kitty_conf)"
  save_setting TERMINAL kitty
  install_workdeck >/dev/null || fail "the update exited with an error"
  assert "the font stays" grep -q '^font_family .*JetBrains Mono' "$(kitty_conf)"
  assert "the theme stays" grep -q '^background ' "$(kitty_conf)"
  assert_equal "$(saved_setting VISUAL)" yes "the look is saved as a choice"
}

test_panel_outside_kitty_with_kitty_chosen_only_reminds() {
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  output="$(TMUX=outside "$CODE/bin/work-panel" --once | sed 's/\x1b\[[0-9;]*m//g')"
  assert_contains "$output" "os atalhos do workdeck ficam no kitty"
  assert_not_contains "$output" "abre direto"
}

test_panel_outside_kitty_keeps_the_notice() {
  install_workdeck >/dev/null || fail "the install exited with an error"
  output="$(TMUX=outside "$CODE/bin/work-panel" --once | sed 's/\x1b\[[0-9;]*m//g')"
  assert_contains "$output" "No kitty, o workdeck abre direto"
}

iterm_profile() { echo "$HOME/Library/Application Support/iTerm2/DynamicProfiles/workdeck.json"; }

old_iterm_install() {
  install_workdeck --terminal other >/dev/null || fail "the first install exited with an error"
  mkdir -p "$(dirname "$(iterm_profile)")"
  cp "$REPO/terminals/iterm2.json" "$(iterm_profile)"
  printf 'iterm-profile|%s|\n' "$(iterm_profile)" >> "$CONFIG/.install-manifest"
}

test_update_removes_the_old_iterm2_profile() {
  old_iterm_install
  output="$(install_workdeck 2>&1)" || fail "the update exited with an error"
  assert "the profile was removed" test ! -e "$(iterm_profile)"
  assert "the manifest forgot it" test -z "$(grep '^iterm-profile|' "$CONFIG/.install-manifest")"
  assert_contains "$output" "profile workdeck do iTerm2 removido"
}

test_update_keeps_an_edited_iterm2_profile() {
  old_iterm_install
  echo " " >> "$(iterm_profile)"
  install_workdeck >/dev/null || fail "the update exited with an error"
  assert "the edited profile stays" test -f "$(iterm_profile)"
}

test_old_terminal_choices_become_other() {
  save_setting TERMINAL warp
  output="$(install_workdeck 2>&1)" || fail "the install exited with an error"
  assert_equal "$(saved_setting TERMINAL)" other "a saved warp"
  assert_contains "$output" "sem kitty"
  output="$(install_workdeck --terminal iterm 2>&1)" || fail "--terminal iterm exited with an error"
  assert_equal "$(saved_setting TERMINAL)" other "--terminal iterm"
  install_workdeck --terminal kitty,iterm >/dev/null || fail "--terminal kitty,iterm exited with an error"
  assert_equal "$(saved_setting TERMINAL)" kitty "a list with kitty"
}

test_kitty_already_installed_is_mentioned() {
  mkdir -p "$HOME/Applications/kitty.app"
  output="$(install_workdeck --terminal kitty 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "o kitty já está instalado"
  assert_not_contains "$output" "o kitty ainda não está instalado"
}

test_uninstall_never_removes_kitty() {
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  mkdir -p "$HOME/Applications/kitty.app"
  printf 'kitty|%s|\n' "$HOME/Applications/kitty.app" >> "$CONFIG/.install-manifest"
  output="$(bash "$CODE/uninstall.sh" --all 2>&1 </dev/null)" || fail "the uninstall exited with an error"
  assert "kitty stays" test -d "$HOME/Applications/kitty.app"
  assert_contains "$output" "o kitty continua instalado"
  assert "the block left kitty.conf" test -z "$(grep '^# >>> workdeck >>>' "$(kitty_conf)" 2>/dev/null)"
}

test_install_picks_the_agent_in_the_path_without_asking() {
  printf '#!/bin/sh\n' > "$BASE/bin/claude"
  chmod +x "$BASE/bin/claude"
  output="$(install_workdeck 2>&1)" || fail "the install exited with an error"
  assert_equal "$(saved_setting AGENT_CMD)" claude "the detected agent"
  assert_contains "$output" "agente: claude"
}

test_kitty_opens_straight_into_work() {
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  assert "the block points to the session" grep -q "^startup_session $CONFIG/kitty-session$" "$(kitty_conf)"
  assert_contains "$(cat "$CONFIG/kitty-session")" "-lc 'command -v tmux >/dev/null || exec "
  assert_contains "$(cat "$CONFIG/kitty-session")" "; $HOME/.local/bin/work; exec "
}

test_kitty_session_respects_the_user_and_the_setting() {
  mkdir -p "$(dirname "$(kitty_conf)")"
  echo 'startup_session ~/my-session' > "$(kitty_conf)"
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  assert_equal "$(grep -c '^startup_session' "$(kitty_conf)")" 1 "startup_session lines with the user's own"
  rm -f "$(kitty_conf)"
  save_setting KITTY_OPENS_WORK no
  install_workdeck --terminal kitty >/dev/null || fail "the second install exited with an error"
  assert "no session with KITTY_OPENS_WORK=no" test -z "$(grep '^startup_session' "$(kitty_conf)")"
}
