theme_applied() {
  local line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    grep -qxF -- "$line" "$HOME/.tmux.conf" || return 1
  done < "$REPO/themes/$1.tmux"
}

test_default_theme() {
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_equal "$(saved_setting THEME)" catppuccin-mocha "saved theme"
  assert "catppuccin colors are in tmux.conf" theme_applied catppuccin-mocha
}

test_chosen_theme_is_kept() {
  install_workdeck --theme nord >/dev/null || fail "install with --theme nord"
  install_workdeck >/dev/null || fail "reinstall without --theme"
  assert_equal "$(saved_setting THEME)" nord "theme after reinstall"
  assert "nord colors stay in tmux.conf" theme_applied nord
}

test_invalid_saved_theme_falls_back_to_default() {
  save_setting THEME does-not-exist
  install_workdeck >/dev/null || fail "install exited with an error"
  assert_equal "$(saved_setting THEME)" catppuccin-mocha "saved theme"
}

test_unknown_theme_fails() {
  if output="$(install_workdeck --theme foo 2>&1)"; then fail "install should fail"; fi
  assert_contains "$output" "tema 'foo' não existe"
  assert_contains "$output" "nord"
}
