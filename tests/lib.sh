fail() {
  echo "FAILED: $*"
  exit 1
}

assert() {
  local description="$1"; shift
  "$@" || fail "$description"
}

assert_equal() {
  [ "$1" = "$2" ] || fail "${3:-values differ}: expected [$2], got [$1]"
}

assert_contains() {
  case "$1" in *"$2"*) ;; *) fail "${3:-text not found}: [$2] is not in [$1]" ;; esac
}

assert_not_contains() {
  case "$1" in *"$2"*) fail "${3:-unexpected text}: [$2] is in [$1]" ;; esac
}

wait_for() {
  local n=0
  while [ "$n" -lt 50 ]; do
    "$@" >/dev/null 2>&1 && return 0
    sleep 0.2
    n=$((n + 1))
  done
  return 1
}

count_blocks() {
  grep -c '^# >>> workdeck >>>$' "$1" 2>/dev/null || true
}

setup_repo() {
  TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/workdeck-tests.XXXXXX")"
  REPO="$TEST_TMP/repo"
  mkdir -p "$REPO"
  if git -C "$ROOT" rev-parse >/dev/null 2>&1; then
    git -C "$ROOT" ls-files -co --exclude-standard | while IFS= read -r f; do
      [ -f "$ROOT/$f" ] || continue
      mkdir -p "$REPO/$(dirname "$f")"
      cp -p "$ROOT/$f" "$REPO/$f"
    done
  else
    (cd "$ROOT" && tar cf - --exclude .git .) | (cd "$REPO" && tar xf -)
  fi
  git -C "$REPO" init -q
  git -C "$REPO" add -A
  git -C "$REPO" -c user.name=test -c user.email=test@example.com commit -qm test
  REAL_TMUX="$(command -v tmux)"
  export TEST_TMP REPO REAL_TMUX
}

setup_home() {
  local name="$1" base="$TEST_TMP/$1" git_dir
  mkdir -p "$base/home/.config/workdeck" "$base/bin"
  SOCKET="wdt-$name-$$"
  SOCKET_HOST="wdh-$name-$$"
  cat > "$base/bin/tmux" <<FAKE
#!/bin/sh
if [ "\$1" = display-menu ] && [ -n "\${WD_MENU_LOG:-}" ]; then printf '%s\n' "\$@" > "\$WD_MENU_LOG"; exit 0; fi
exec "$REAL_TMUX" -L "$SOCKET" "\$@"
FAKE
  chmod +x "$base/bin/tmux"
  echo no > "$base/home/.config/workdeck/zsh"
  unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME TMUX KITTY_WINDOW_ID WARP_CLIENT_VERSION WORKDECK_SESSION
  export HOME="$base/home"
  git_dir="$(dirname "$(command -v git)")"
  export PATH="$base/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$git_dir"
  export SHELL=/bin/bash TERM=xterm-256color NO_COLOR=1
  export SOCKET SOCKET_HOST
  export CONFIG="$HOME/.config/workdeck"
  export CODE="$HOME/.local/share/workdeck"
  export BASE="$base"
}

cleanup_tmux() {
  "$REAL_TMUX" -L "$SOCKET" kill-server >/dev/null 2>&1 || true
  "$REAL_TMUX" -L "$SOCKET_HOST" kill-server >/dev/null 2>&1 || true
}

install_workdeck() {
  bash "$REPO/install.sh" --yes --no-deps --no-reload "$@" </dev/null
}

shell_rc_file() {
  if [ "$(uname -s)" = Darwin ]; then echo "$HOME/.bash_profile"; else echo "$HOME/.bashrc"; fi
}

open_work_in_terminal() {
  "$REAL_TMUX" -L "$SOCKET_HOST" -f /dev/null new-session -d -s host -x 120 -y 40 \
    "env -i HOME='$HOME' PATH='$PATH' SHELL=/bin/bash TERM=xterm-256color bash --norc --noprofile"
  wait_for "$REAL_TMUX" -L "$SOCKET_HOST" has-session -t host || fail "the test terminal did not open"
  "$REAL_TMUX" -L "$SOCKET_HOST" send-keys -t host "$*" Enter
}
