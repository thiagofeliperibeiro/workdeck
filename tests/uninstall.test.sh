test_uninstall_all() {
  install_workdeck >/dev/null || fail "install exited with an error"
  bash "$CODE/uninstall.sh" --all >/dev/null || fail "uninstall exited with an error"
  assert "work was removed" test ! -e "$HOME/.local/bin/work"
  assert "the code was removed" test ! -e "$CODE"
  assert "the config was removed" test ! -e "$CONFIG"
  assert "the tmux.conf created by install was removed" test ! -e "$HOME/.tmux.conf"
}

test_restore_brings_back_the_original() {
  printf 'set -g history-limit 5000\n' > "$HOME/.tmux.conf"
  before="$(cksum < "$HOME/.tmux.conf")"
  install_workdeck >/dev/null || fail "install exited with an error"
  bash "$CODE/uninstall.sh" --restore >/dev/null || fail "uninstall exited with an error"
  assert_equal "$(cksum < "$HOME/.tmux.conf")" "$before" "tmux.conf after --restore"
}

test_uninstall_removes_only_the_block() {
  printf 'set -g history-limit 5000\n' > "$HOME/.tmux.conf"
  install_workdeck >/dev/null || fail "install exited with an error"
  bash "$CODE/uninstall.sh" >/dev/null || fail "uninstall exited with an error"
  assert_equal "$(count_blocks "$HOME/.tmux.conf")" 0 "blocks in tmux.conf"
  assert "the user's line is kept" grep -qx 'set -g history-limit 5000' "$HOME/.tmux.conf"
  assert "the config is kept" test -d "$CONFIG"
}

test_uninstall_reads_a_legacy_manifest() {
  install_workdeck >/dev/null || fail "install exited with an error"
  sed -i.bak -e 's/^block|/bloco|/' -e 's/^code|/codigo|/' -e 's/|:created$/|:criado/' "$CONFIG/.install-manifest"
  bash "$CODE/uninstall.sh" --all >/dev/null || fail "uninstall exited with an error"
  assert "the code was removed" test ! -e "$CODE"
  assert "the tmux.conf created by install was removed" test ! -e "$HOME/.tmux.conf"
}

test_uninstall_removes_only_the_zsh_key() {
  install_workdeck >/dev/null || fail "install exited with an error"
  save_setting THEME nord
  save_setting ZSH yes
  mkdir -p "$HOME/.oh-my-zsh"
  echo "omz|$HOME/.oh-my-zsh|" >> "$CONFIG/.install-manifest"
  bash "$CODE/uninstall.sh" >/dev/null || fail "uninstall exited with an error"
  assert "oh-my-zsh was removed" test ! -e "$HOME/.oh-my-zsh"
  assert "the ZSH key is gone" lacks_saved_setting ZSH
  assert_equal "$(saved_setting THEME)" nord "the other choices are kept"
}
