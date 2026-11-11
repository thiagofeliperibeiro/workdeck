test_update_follows_a_republished_tag() {
  git -C "$REPO" tag v1.0.0
  install_workdeck >/dev/null || fail "the install exited with an error"
  git -C "$CODE" fetch -q --tags origin
  git -C "$REPO" -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m next
  git -C "$REPO" tag -f v1.0.0 >/dev/null
  output="$("$HOME/.local/bin/work" update 2>&1 </dev/null)"
  assert_not_contains "$output" "não consegui falar com o repositório"
  assert_equal "$(git -C "$CODE" rev-parse 'v1.0.0^{commit}')" "$(git -C "$REPO" rev-parse HEAD)" "v1.0.0 in the installed copy"
}

test_update_check_runs_without_errors() {
  install_workdeck >/dev/null || fail "the install exited with an error"
  output="$(work update --check 2>&1)" || fail "work update --check exited with an error"
  assert_not_contains "$output" "not found"
  wait_for test -s "$HOME/.cache/workdeck/update" || fail "the background check did not write the cache"
}

test_update_check_asks_the_site_first() {
  install_workdeck >/dev/null || fail "the install exited with an error"
  printf 'v9.9.9\n' > "$HOME/version"
  WORKDECK_VERSION_URL="file://$HOME/version" work update --check >/dev/null 2>&1 || fail "work update --check exited with an error"
  wait_for grep -q '^latest=v9.9.9$' "$HOME/.cache/workdeck/update" || fail "the version from the site did not reach the cache"
}

test_update_check_falls_back_to_git_when_the_site_answers_junk() {
  git -C "$REPO" tag v1.2.3
  install_workdeck >/dev/null || fail "the install exited with an error"
  printf '<html>oops</html>\n' > "$HOME/version"
  WORKDECK_VERSION_URL="file://$HOME/version" work update --check >/dev/null 2>&1 || fail "work update --check exited with an error"
  wait_for grep -qE '^latest=v[0-9]+\.[0-9]+\.[0-9]+$' "$HOME/.cache/workdeck/update" || fail "the git fallback did not reach the cache"
}

test_update_falls_back_to_https_for_a_github_ssh_remote() {
  git -C "$REPO" tag v1.0.0
  install_workdeck >/dev/null || fail "the install exited with an error"
  git -C "$CODE" remote set-url origin git@github.com:owner/workdeck.git
  # Offline stand-ins: the SSH remote fails at once, the HTTPS one is the test repo.
  git config --global url."file:///nonexistent/".insteadOf git@github.com:
  git config --global url."file://$REPO".insteadOf https://github.com/owner/workdeck.git
  output="$("$HOME/.local/bin/work" update 2>&1 </dev/null)"
  assert_not_contains "$output" "não consegui falar com o repositório"
  assert_equal "$(git -C "$CODE" config --get remote.origin.url)" https://github.com/owner/workdeck.git "remote after the update"
}

test_update_shows_the_git_error_when_the_repository_is_unreachable() {
  install_workdeck >/dev/null || fail "the install exited with an error"
  git -C "$CODE" remote set-url origin "file://$HOME/no-such-repo"
  output="$("$HOME/.local/bin/work" update 2>&1 </dev/null)"
  assert_contains "$output" "não consegui falar com o repositório"
  assert_contains "$output" "o git respondeu:"
  assert_equal "$(git -C "$CODE" config --get remote.origin.url)" "file://$HOME/no-such-repo" "remote left as it was"
}
