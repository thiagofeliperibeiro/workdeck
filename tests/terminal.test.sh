warp_themes_dir() {
  if [ "$(uname -s)" = Darwin ]; then
    echo "$HOME/.warp/themes"
    return 0
  fi
  echo "$HOME/.local/share/warp-terminal/themes"
}

kitty_conf() { echo "$HOME/.config/kitty/kitty.conf"; }

test_terminal_kitty_installed_gets_the_block() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  assert "the block was written to kitty.conf" grep -q '^# >>> workdeck >>>$' "$(kitty_conf)"
  assert_equal "$(cat "$CONFIG/terminal")" kitty "saved choice"
}

test_terminal_kitty_missing_warns_and_downloads_nothing() {
  output="$(install_workdeck --terminal kitty 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "kitty não encontrado; instale por https://sw.kovidgoyal.net/kitty/binary/"
  assert "no kitty.conf was created" test ! -e "$(kitty_conf)"
  assert "nothing was downloaded" test ! -e "$HOME/Applications/kitty.app"
}

test_terminal_other_leaves_the_terminal_alone() {
  mkdir -p "$HOME/Applications/kitty.app"
  output="$(install_workdeck --terminal other 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "sem ajustes"
  assert "no kitty.conf was created" test ! -e "$(kitty_conf)"
  assert "no visual choice was saved" test ! -e "$CONFIG/visual"
}

test_saved_terminal_applies_on_reinstall() {
  install_workdeck --terminal other >/dev/null || fail "the install exited with an error"
  mkdir -p "$HOME/Applications/kitty.app"
  output="$(install_workdeck 2>&1)" || fail "the reinstall exited with an error"
  assert_contains "$output" "sem ajustes" "the saved choice"
  assert "kitty.conf still has no block" test ! -e "$(kitty_conf)"
}

test_requested_terminal_wins_over_saved() {
  echo other > "$CONFIG/terminal"
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty >/dev/null || fail "the install exited with an error"
  assert_equal "$(cat "$CONFIG/terminal")" kitty "saved choice"
  assert "the block was written to kitty.conf" grep -q '^# >>> workdeck >>>$' "$(kitty_conf)"
}

test_terminal_without_a_question_uses_the_detected_one_and_saves_nothing() {
  export KITTY_WINDOW_ID=1
  output="$(install_workdeck 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "kitty não encontrado" "the detected terminal"
  assert "nothing was saved without a choice" test ! -e "$CONFIG/terminal"
}

test_install_shows_the_choices_and_how_to_change_them() {
  mkdir -p "$HOME/Applications/kitty.app"
  output="$(install_workdeck --terminal kitty --no-visual 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "terminal  kitty"
  assert_contains "$output" "./install.sh --terminal kitty|warp|other"
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
  assert_contains "$output" "terminal  outro"
  assert_not_contains "$output" "visual    "
}

test_unknown_terminal_fails() {
  if output="$(install_workdeck --terminal foo 2>&1)"; then fail "the install should fail"; fi
  assert_contains "$output" "terminal 'foo' não existe"
  assert_contains "$output" "kitty, warp, other"
}

test_visual_on_kitty_puts_theme_and_font_in_the_block() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty --visual >/dev/null || fail "the install exited with an error"
  assert "the theme colors" grep -q '^background ' "$(kitty_conf)"
  assert "the font" grep -q '^font_family .*JetBrains Mono' "$(kitty_conf)"
  assert "the padding" grep -q '^window_padding_width 8$' "$(kitty_conf)"
  assert "the shortcuts" grep -q '^map cmd+1 ' "$(kitty_conf)"
  assert_equal "$(cat "$CONFIG/visual")" yes "saved choice"
}

test_no_visual_on_kitty_writes_only_the_shortcuts() {
  mkdir -p "$HOME/Applications/kitty.app"
  install_workdeck --terminal kitty --no-visual >/dev/null || fail "the install exited with an error"
  assert "the shortcuts" grep -q '^map cmd+1 ' "$(kitty_conf)"
  assert "Option as Alt" grep -q '^macos_option_as_alt' "$(kitty_conf)"
  assert "no colors" test -z "$(grep '^background \|^color0 ' "$(kitty_conf)")"
  assert "no font" test -z "$(grep '^font_family' "$(kitty_conf)")"
  assert "no padding" test -z "$(grep '^window_padding_width' "$(kitty_conf)")"
  assert_equal "$(cat "$CONFIG/visual")" no "saved choice"
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
  assert "the shortcuts" grep -q '^map cmd+1 ' "$(kitty_conf)"
  assert "no colors" test -z "$(grep '^background ' "$(kitty_conf)")"
  assert "nothing was saved without a choice" test ! -e "$CONFIG/visual"
}

test_update_keeps_the_kitty_look_of_an_older_install() {
  mkdir -p "$HOME/Applications/kitty.app" "$(dirname "$(kitty_conf)")"
  printf '%s\n' '# >>> workdeck >>>' 'map cmd+1 send_text all \x021' 'font_family        JetBrains Mono' 'background #1e1e2e' '# <<< workdeck <<<' > "$(kitty_conf)"
  echo kitty > "$CONFIG/terminal"
  install_workdeck >/dev/null || fail "the update exited with an error"
  assert "the font stays" grep -q '^font_family .*JetBrains Mono' "$(kitty_conf)"
  assert "the theme stays" grep -q '^background ' "$(kitty_conf)"
  assert_equal "$(cat "$CONFIG/visual")" yes "the look is saved as a choice"
}

test_warp_with_visual_gets_the_chosen_theme() {
  export WARP_CLIENT_VERSION=test
  output="$(install_workdeck --terminal warp --visual --theme nord 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "Warp encontrado"
  assert "the nord theme is in the Warp folder" cmp -s "$REPO/themes/nord.warp.yaml" "$(warp_themes_dir)/workdeck-nord.yaml"
  assert "only the chosen theme was copied" test ! -e "$(warp_themes_dir)/workdeck-min-dark.yaml"
  assert "no kitty.conf was created" test ! -e "$(kitty_conf)"
}

test_warp_without_visual_writes_nothing() {
  export WARP_CLIENT_VERSION=test
  install_workdeck --terminal warp --no-visual >/dev/null || fail "the install exited with an error"
  assert "no theme was copied" test ! -e "$(warp_themes_dir)"
}

test_warp_dry_run_writes_nothing() {
  export WARP_CLIENT_VERSION=test
  install_workdeck --terminal warp --visual --dry-run >/dev/null || fail "the dry run exited with an error"
  assert "no theme was copied" test ! -e "$(warp_themes_dir)"
}

test_warp_reinstall_does_not_duplicate_the_manifest_entry() {
  export WARP_CLIENT_VERSION=test
  install_workdeck --terminal warp --visual >/dev/null || fail "the install exited with an error"
  install_workdeck >/dev/null || fail "the reinstall exited with an error"
  assert_equal "$(grep -c '^warp-theme|' "$CONFIG/.install-manifest")" 1 "theme entries in the manifest"
}

test_warp_explains_how_to_pick_theme_and_font() {
  export WARP_CLIENT_VERSION=test
  output="$(install_workdeck --terminal warp --visual 2>&1)" || fail "the install exited with an error"
  assert_contains "$output" "Settings › Appearance › Themes"
  assert_contains "$output" "workdeck catppuccin-mocha"
  assert_contains "$output" "Settings › Appearance › Text › Font type"
}

test_warp_explains_the_option_key_only_on_a_mac() {
  export WARP_CLIENT_VERSION=test
  output="$(install_workdeck --terminal warp --no-visual 2>&1)" || fail "the install exited with an error"
  if [ "$(uname -s)" = Darwin ]; then
    assert_contains "$output" 'Left Option key is Meta'
    return 0
  fi
  assert_not_contains "$output" 'Left Option key is Meta'
  assert_not_contains "$output" 'No Warp, falta escolher' "the heading with nothing below it"
}

test_warp_without_visual_does_not_explain_theme_or_font() {
  export WARP_CLIENT_VERSION=test
  output="$(install_workdeck --terminal warp --no-visual 2>&1)" || fail "the install exited with an error"
  assert_not_contains "$output" "Settings › Appearance › Themes"
}

test_warp_uninstall_removes_the_theme() {
  export WARP_CLIENT_VERSION=test
  install_workdeck --terminal warp --visual >/dev/null || fail "the install exited with an error"
  assert "the theme was copied" test -f "$(warp_themes_dir)/workdeck-catppuccin-mocha.yaml"
  bash "$REPO/uninstall.sh" >/dev/null || fail "the uninstaller exited with an error"
  assert "the theme left the Warp folder" test ! -e "$(warp_themes_dir)/workdeck-catppuccin-mocha.yaml"
}

test_warp_uninstall_keeps_an_edited_theme() {
  export WARP_CLIENT_VERSION=test
  install_workdeck --terminal warp --visual >/dev/null || fail "the install exited with an error"
  echo "# my tweak" >> "$(warp_themes_dir)/workdeck-catppuccin-mocha.yaml"
  output="$(bash "$REPO/uninstall.sh")" || fail "the uninstaller exited with an error"
  assert_contains "$output" "foi alterado depois da instalação"
  assert "the edited theme stays" test -f "$(warp_themes_dir)/workdeck-catppuccin-mocha.yaml"
}

test_panel_in_warp_explains_the_limits() {
  install_workdeck >/dev/null || fail "the install exited with an error"
  output="$(TMUX=outside WARP_CLIENT_VERSION=test "$CODE/bin/work-panel" --once | sed 's/\x1b\[[0-9;]*m//g')"
  assert_contains "$output" "No Warp"
  assert_not_contains "$output" "Fora do kitty"
}

test_panel_outside_kitty_and_warp_keeps_the_notice() {
  install_workdeck >/dev/null || fail "the install exited with an error"
  output="$(TMUX=outside "$CODE/bin/work-panel" --once | sed 's/\x1b\[[0-9;]*m//g')"
  assert_contains "$output" "Fora do kitty"
}
