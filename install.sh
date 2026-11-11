#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/common.sh"

CONFIG_DIR="$WORKDECK_CONFIG"
BIN_DIR="$WORKDECK_BIN"
CODE="$WORKDECK_CODE"
BACKUPS="$CONFIG_DIR/.backups"
MANIFEST="$CONFIG_DIR/.install-manifest"
ZSH_PLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck-zsh"
ZINIT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
APPS_DIR="${WORKDECK_APPS_DIR:-/Applications}"
KITTY_DOWNLOAD="https://sw.kovidgoyal.net/kitty/binary/"
ITERM_PROFILE="$HOME/Library/Application Support/iTerm2/DynamicProfiles/workdeck.json"
KITTY_SESSION="$WORKDECK_CONFIG/kitty-session"

THEME=""
LANGUAGE=""
LANGUAGE_REQUESTED=""
CLOCK_REQUESTED=""
TCLOCK_REPO="https://github.com/akitaonrails/clock-tui"
WANT_ZSH=0
TERMINAL=""
TERMINAL_REQUESTED=""
VISUAL=""
VISUAL_REQUESTED=""
RESTART_SHELL=0
SHELL_CHANGED=0
KITTY_CHANGED=0
QUICK_ACCESS=0
BLOCK_CHANGED=0
AGENT=""
WITH=""
YES=0
DEPS=1
RELOAD=1
DRY=0

OS_NAME=""
PKG_MANAGER=""
SUDO=""
FONTS_DIR=""
ZSH_SUMMARY=""

FANCY=0
green=""; yellow=""; red=""; purple=""; dim=""; bold=""; reset=""
LOG=""
UPDATING="${WORKDECK_UPDATING:-${WORKDECK_ATUALIZANDO:-}}"
STEP=""; STEP_NUMBER=0; SUMMARY=""; WARNINGS=(); SPINNER=""; STATUS_FILE=""

parse_options() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --theme) THEME="$(option_value "$@")"; shift 2 ;;
      --agent) AGENT="$(option_value "$@")"; shift 2 ;;
      --with) WITH="$(option_value "$@")"; shift 2 ;;
      --lang)
        LANGUAGE_REQUESTED="$(option_value "$@")"
        valid_language "$LANGUAGE_REQUESTED" || { msgln install_bad_lang "$LANGUAGE_REQUESTED"; exit 1; }
        load_messages "$LANGUAGE_REQUESTED"
        shift 2 ;;
      --yes|-y) YES=1; shift ;;
      --list-integrations) list_integrations; exit 0 ;;
      --terminal)
        TERMINAL_REQUESTED="$(option_value "$@")"
        valid_terminal "$TERMINAL_REQUESTED" || { msgln install_bad_terminal "$TERMINAL_REQUESTED"; exit 1; }
        TERMINAL_REQUESTED="$(normalize_terminal "$TERMINAL_REQUESTED")"
        shift 2 ;;
      --visual) VISUAL_REQUESTED=yes; shift ;;
      --clock) CLOCK_REQUESTED=yes; shift ;;
      --no-clock) CLOCK_REQUESTED=no; shift ;;
      --no-visual) VISUAL_REQUESTED=no; shift ;;
      --no-deps) DEPS=0; shift ;;
      --zsh) WANT_ZSH=1; shift ;;
      --no-reload) RELOAD=0; shift ;;
      --dry-run) DRY=1; shift ;;
      -h|--help) msgln install_help; exit 0 ;;
      *) msgln install_unknown_option "$1"; exit 1 ;;
    esac
  done
}

option_value() {
  if [ $# -lt 2 ] || [ -z "$2" ]; then msg install_needs_value "$1" >&2; echo >&2; exit 1; fi
  printf '%s' "$2"
}

valid_language() {
  case "$1" in
    en|pt-BR) return 0 ;;
    *) return 1 ;;
  esac
}

language_name() {
  case "$1" in
    pt-BR) echo Português ;;
    *) echo English ;;
  esac
}

ask_language() {
  local answer
  echo
  echo "  $(msg install_ask_language)"
  echo "    1) English"
  echo "    2) Português"
  echo
  printf '  %s' "$(msg install_ask_number "$(language_name "$LANGUAGE")")"
  read -r answer || answer=""
  case "$answer" in
    1) LANGUAGE=en ;;
    2) LANGUAGE=pt-BR ;;
  esac
}

choose_language() {
  LANGUAGE="${LANGUAGE_REQUESTED:-$(setting_get LANGUAGE)}"
  if ! valid_language "$LANGUAGE"; then
    if [ -f "$MANIFEST" ]; then LANGUAGE=pt-BR; else LANGUAGE="$(workdeck_language)"; fi
    load_messages "$LANGUAGE"
    can_ask && ask_language
  fi
  load_messages "$LANGUAGE"
}

list_integrations() {
  local f
  for f in "$ROOT"/integrations/*.sh; do
    [ "$(basename "$f")" = "example.sh" ] && continue
    ( . "$f"; printf '  %s\n' "$(describe | head -1)"
      describe | tail -n +2 | sed 's/^/      /' )
    echo
  done
}

record() {
  [ "$DRY" = 1 ] && return 0
  mkdir -p "$(dirname "$MANIFEST")"
  grep -qxF "$1|$2|${3:-}" "$MANIFEST" 2>/dev/null || echo "$1|$2|${3:-}" >> "$MANIFEST"
}

backup_file() {
  local file="$1" name dest
  [ -f "$file" ] || return 0
  has_block "$file" && return 0
  name="$(echo "${file#"$HOME"/}" | tr '/' '-' | sed 's/^\.//')"
  dest="$BACKUPS/$name.$(date +%Y%m%d-%H%M%S)"
  [ "$DRY" = 1 ] && { echo ""; return 0; }
  mkdir -p "$BACKUPS"
  cp "$file" "$dest"
  echo "$dest"
}

write_block() {
  local file="$1" body="$2" tmp backup before
  BLOCK_CHANGED=0
  if [ -e "$file" ] && [ ! -f "$file" ]; then
    warn "$(msg install_not_regular "$(short_path "$file")")"
    return 0
  fi
  backup="$(backup_file "$file")"
  [ -n "$backup" ] && say "$(msg install_backup "${backup#"$HOME"/}")"
  [ -e "$file" ] || backup=":created"
  grep -qF "block|$file|" "$MANIFEST" 2>/dev/null || record block "$file" "$backup"
  [ "$DRY" = 1 ] && { say "$(msg install_dry_block "$file")"; return 0; }
  mkdir -p "$(dirname "$file")"
  touch "$file"
  before="$(cksum < "$file")"
  tmp="$(mktemp)"
  without_block "$file" > "$tmp"
  awk 'BEGIN{n=0} {l[n++]=$0} END{while(n>0 && l[n-1]~/^[[:space:]]*$/) n--; for(i=0;i<n;i++) print l[i]}' "$tmp" > "$tmp.2"
  { cat "$tmp.2"; [ -s "$tmp.2" ] && echo; echo "$body"; } > "$file"
  rm -f "$tmp" "$tmp.2"
  [ "$(cksum < "$file")" = "$before" ] || BLOCK_CHANGED=1
}

can_ask() {
  [ -t 0 ] || return 1
  [ "$YES" = 0 ] || [ -n "$UPDATING" ]
}

say() {
  if [ "$FANCY" = 1 ]; then
    printf '%s\n' "$*" >> "$LOG"
    printf '%s' "$*" > "$STATUS_FILE"
  else
    printf '  %s\n' "$*"
  fi
}
warn() {
  [ "$FANCY" = 1 ] && WARNINGS+=("$*")
  say "$*"
}
summary() { SUMMARY="$*"; }
run() {
  [ "$DRY" = 1 ] && { say "[dry-run] $*"; return 0; }
  if [ "$FANCY" = 1 ]; then "$@" >> "$LOG" 2>&1; else "$@"; fi
}

spin() {
  [ "$FANCY" = 1 ] || return 0
  : > "$STATUS_FILE"
  (
    frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏); i=0
    cols="$(tput cols 2>/dev/null || echo 80)"
    room=$((cols - 30))
    while :; do
      status="$(cat "$STATUS_FILE" 2>/dev/null)"
      [ "${#status}" -le "$room" ] || status="${status:0:$((room - 1))}…"
      printf '\r\033[K  %s%s%s %s %s%s/7  %s%s' "$purple" "${frames[$((i % 10))]}" "$reset" "$STEP" "$dim" "$STEP_NUMBER" "$status" "$reset"
      i=$((i + 1)); sleep 0.08
    done
  ) &
  SPINNER=$!
}
stop_spin() {
  if [ -n "$SPINNER" ]; then
    kill "$SPINNER" 2>/dev/null || true
    wait "$SPINNER" 2>/dev/null || true
    SPINNER=""
    printf '\r\033[K'
  fi
  return 0
}
step() {
  STEP="$2"; STEP_NUMBER="$1"; SUMMARY=""; WARNINGS=()
  if [ "$FANCY" = 1 ]; then spin; else echo "[$1/7] $2"; fi
}
finish_step() {
  local a mark width
  if [ "$FANCY" = 1 ]; then
    stop_spin
    mark="${green}✓${reset}"
    [ ${#WARNINGS[@]} -gt 0 ] && mark="${yellow}!${reset}"
    width=$(printf '%s' "$STEP" | LC_ALL=C tr -d '\200-\277' | wc -c)
    printf '  %s %s%*s %s%s%s\n' "$mark" "$STEP" $((16 - width)) "" "$dim" "$SUMMARY" "$reset"
    for a in ${WARNINGS[@]+"${WARNINGS[@]}"}; do printf '      %s%s%s\n' "$yellow" "$a" "$reset"; done
  else
    echo
  fi
  STEP=""
}
on_exit() {
  local status=$?
  stop_spin
  if [ "$status" != 0 ] && [ "$FANCY" = 1 ] && [ -n "$STEP" ]; then
    printf '  %s✗%s %s\n' "$red" "$reset" "$STEP"
    tail -n 15 "$LOG" | sed 's/^/      /'
  fi
  [ "$FANCY" = 1 ] && printf '\033[?25h'
  rm -f "$LOG" "$STATUS_FILE"
}

setup_output() {
  if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != dumb ] && [ "$DRY" = 0 ]; then FANCY=1; fi
  if [ "$FANCY" = 1 ]; then
    green=$'\033[32m'; yellow=$'\033[33m'; red=$'\033[31m'; purple=$'\033[35m'
    dim=$'\033[2m'; bold=$'\033[1m'; reset=$'\033[0m'
  fi
  LOG="$(mktemp)"
  STATUS_FILE="$(mktemp)"
  trap on_exit EXIT
  if [ "$FANCY" = 1 ]; then exec 2>>"$LOG"; fi
}

choose_theme() {
  local saved
  saved="$(setting_get THEME)"
  if [ -z "$THEME" ]; then
    THEME="$saved"
    [ -f "$ROOT/themes/${THEME:-_}.conf" ] || THEME="catppuccin-mocha"
  fi
  if [ ! -f "$ROOT/themes/$THEME.conf" ]; then
    local t
    msgln install_bad_theme "$THEME"
    for t in "$ROOT"/themes/*.conf; do t="$(basename "$t")"; echo "  ${t%.conf}"; done
    exit 1
  fi
  save_choice THEME "$THEME"
}

detect_system() {
  local g
  case "$(uname -s)" in
    Darwin) OS_NAME="macOS"; PKG_MANAGER="brew" ;;
    Linux)
      OS_NAME="Linux"
      if grep -qi microsoft /proc/version 2>/dev/null; then OS_NAME="Linux (WSL)"; fi
      for g in apt-get dnf pacman zypper apk; do
        command -v "$g" >/dev/null && { PKG_MANAGER="$g"; break; }
      done
      ;;
    *) OS_NAME="$(uname -s)" ;;
  esac
  [ "$(id -u)" != 0 ] && SUDO="sudo"
  if [ "$OS_NAME" = macOS ]; then FONTS_DIR="$HOME/Library/Fonts"; else FONTS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"; fi
}

show_header() {
  if [ "$FANCY" = 1 ]; then
    if [ -n "$UPDATING" ]; then
      printf '\033[?25l'
    else
      printf '\033[?25l\n  %sworkdeck%s %s%s%s · %s%s\n\n' "$bold" "$reset" "$dim" "${VERSION:+$VERSION · }" "$OS_NAME" "$THEME" "$reset"
    fi
  else
    msgln install_header_plain "$OS_NAME" "$THEME"
    echo
  fi
}

in_kitty() { [ -n "${KITTY_WINDOW_ID:-}" ] || [ "${TERM:-}" = xterm-kitty ]; }

kitty_from_other_account() {
  case "$1" in
    "$HOME"/*) return 1 ;;
    /Users/*|/home/*) return 0 ;;
  esac
  return 1
}

kitty_installed() {
  local k
  [ -d "$APPS_DIR/kitty.app" ] || [ -d "$HOME/Applications/kitty.app" ] \
    || [ -x "$HOME/.local/kitty.app/bin/kitty" ] && return 0
  k="$(command -v kitty 2>/dev/null)" || return 1
  ! kitty_from_other_account "$k"
}

kitty_opens_work() {
  [ "$(setting_get KITTY_OPENS_WORK yes)" = no ] && return 1
  [ -f "$HOME/.config/kitty/kitty.conf" ] && without_block "$HOME/.config/kitty/kitty.conf" | grep -q '^[[:space:]]*startup_session' && return 1
  return 0
}

kitty_work_command() {
  local shell_bin="${SHELL:-/bin/zsh}"
  printf "%s -lc 'command -v tmux >/dev/null || exec %s -lic \"work; exec %s -l\"; %s/work; exec %s -l'" \
    "$shell_bin" "$shell_bin" "$shell_bin" "$BIN_DIR" "$shell_bin"
}

write_kitty_session() {
  [ "$DRY" = 1 ] && return 0
  mkdir -p "$(dirname "$KITTY_SESSION")"
  printf 'launch --title workdeck %s\n' "$(kitty_work_command)" > "$KITTY_SESSION"
}

apply_kitty() {
  local block
  block="$(sed '$d' "$ROOT/terminals/kitty.conf" | sed '/^# The theme is appended here/d')"
  [ "$OS_NAME" = macOS ] || block="$(printf '%s\n' "$block" | grep -v '^macos_' | sed 's/^map cmd+\([^ ]*\)/map ctrl+shift+\1/')"
  if [ "$VISUAL" = yes ]; then
    block="$(printf '%s\n\n%s\n%s\n' "$block" "$(cat "$ROOT/terminals/kitty-visual.conf")" "$(cat "$ROOT/themes/$THEME.conf")")"
  fi
  if kitty_opens_work; then
    write_kitty_session
    block="$(printf '%s\n\nstartup_session %s\n' "$block" "$KITTY_SESSION")"
    say "$(msg install_kitty_session)"
  fi
  write_block "$HOME/.config/kitty/kitty.conf" "$(printf '%s\n' "$block"; echo '# <<< workdeck <<<')"
  KITTY_CHANGED="$BLOCK_CHANGED"
  if kitty_opens_work; then
    write_block "$HOME/.config/kitty/quick-access-terminal.conf" "$(printf '%s\n' '# >>> workdeck >>>' 'edge center-sized' 'lines 40' 'columns 160' 'hide_on_focus_loss yes' 'kitty_override startup_session=none' "kitty_override shell=$(kitty_work_command)" '# <<< workdeck <<<')"
    QUICK_ACCESS=1
  fi
  if [ "$VISUAL" = yes ]; then say "$(msg install_kitty_full)"; else say "$(msg install_kitty_keys)"; fi
}

kitty_block_has_visual() {
  sed -n '/^# >>> workdeck >>>$/,/^# <<< workdeck <<<$/p' "$HOME/.config/kitty/kitty.conf" 2>/dev/null \
    | grep -q '^font_family'
}

in_warp() { [ -n "${WARP_CLIENT_VERSION:-}" ]; }

on_macos() { [ "$(uname -s)" = Darwin ]; }

uses_kitty() { [ "$TERMINAL" = kitty ]; }

current_terminal_name() {
  if in_kitty; then echo kitty
  elif in_warp; then echo Warp
  else echo terminal
  fi
}

warp_installed() {
  in_warp && return 0
  [ -d "$APPS_DIR/Warp.app" ] || [ -d "$HOME/Applications/Warp.app" ] && return 0
  command -v warp-terminal >/dev/null
}

valid_terminal() {
  local t
  [ -n "$1" ] || return 1
  for t in ${1//,/ }; do
    case "$t" in
      kitty|other|warp|iterm) ;;
      *) return 1 ;;
    esac
  done
  return 0
}

normalize_terminal() {
  case ",$1," in
    *,kitty,*) echo kitty ;;
    ,,) ;;
    *) echo other ;;
  esac
}
detected_terminal() {
  if in_kitty || kitty_installed; then echo kitty; else echo other; fi
}
chosen_terminal_name() {
  if uses_kitty; then echo kitty; else msgln install_other_terminal; fi
}
ask_terminal() {
  local answer default=n prompt
  stop_spin
  echo
  [ "$TERMINAL" = kitty ] && default=s
  if on_macos; then prompt="$(msg install_ask_kitty)"; else prompt="$(msg install_ask_kitty_linux)"; fi
  printf '%s\n' "$prompt" | sed 's/^/  /'
  if [ "$default" = s ]; then printf '  %s' "$(msg install_ask_kitty_default_yes)"; else printf '  %s' "$(msg install_ask_kitty_default_no)"; fi
  read -r answer || answer=""
  spin
  case "${answer:-$default}" in
    s|S|y|Y) TERMINAL=kitty ;;
    *) TERMINAL=other ;;
  esac
}
# A key that already holds this value is left alone, so a reinstall does not
# rewrite the user's file.
save_choice() {
  [ "$DRY" = 1 ] && return 0
  setting_has "$1" && [ "$(setting_get "$1")" = "$2" ] && return 0
  setting_set "$1" "$2"
}

choose_terminal() {
  TERMINAL="${TERMINAL_REQUESTED:-$(normalize_terminal "$(setting_get TERMINAL)")}"
  if valid_terminal "$TERMINAL"; then
    save_choice TERMINAL "$TERMINAL"
    return 0
  fi
  TERMINAL="$(detected_terminal)"
  can_ask || return 0
  ask_terminal
  save_choice TERMINAL "$TERMINAL"
}

terminal_has_visual() { uses_kitty; }

ask_visual() {
  local answer
  stop_spin
  echo
  if has_font; then printf '  %s' "$(msg install_ask_theme kitty)"; else printf '  %s' "$(msg install_ask_visual kitty)"; fi
  read -r answer || answer=n
  spin
  case "${answer:-n}" in
    s|S|y|Y) VISUAL=yes ;;
    *) VISUAL=no ;;
  esac
}

choose_visual() {
  VISUAL=""
  terminal_has_visual || return 0
  VISUAL="${VISUAL_REQUESTED:-$(setting_get VISUAL)}"
  if [ "$VISUAL" = yes ] || [ "$VISUAL" = no ]; then
    save_choice VISUAL "$VISUAL"
    return 0
  fi
  if uses_kitty && kitty_block_has_visual; then
    VISUAL=yes
    save_choice VISUAL "$VISUAL"
    return 0
  fi
  VISUAL=no
  can_ask || return 0
  ask_visual
  save_choice VISUAL "$VISUAL"
}

offer_kitty_download() {
  local answer app
  if kitty_installed; then
    in_kitty || say "$(msg install_kitty_present)"
    return 0
  fi
  if [ "$DEPS" = 0 ] || [ "$DRY" = 1 ] || ! can_ask || ! command -v curl >/dev/null; then
    warn "$(msg install_kitty_missing "$KITTY_DOWNLOAD")"
    return 0
  fi
  stop_spin
  printf '  %s' "$(msg install_ask_download_kitty)"
  read -r answer || answer=n
  spin
  case "${answer:-s}" in
    s|S|y|Y) ;;
    *) warn "$(msg install_kitty_missing "$KITTY_DOWNLOAD")"; return 0 ;;
  esac
  say "$(msg install_kitty_downloading)"
  if curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh 2>> "$LOG" | sh /dev/stdin launch=n >> "$LOG" 2>&1; then
    if on_macos; then app="$HOME/Applications/kitty.app"; else app="$HOME/.local/kitty.app"; fi
    if ! on_macos && [ -x "$app/bin/kitty" ]; then
      mkdir -p "$BIN_DIR"
      ln -sf "$app/bin/kitty" "$app/bin/kitten" "$BIN_DIR/"
    fi
    record kitty "$app"
    say "$(msg install_kitty_installed "$(short_path "$app")")"
  else
    warn "$(msg install_kitty_download_failed "$KITTY_DOWNLOAD")"
  fi
}

configure_kitty() {
  apply_kitty
  offer_kitty_download
  if [ "$VISUAL" = yes ]; then
    install_font
    summary "$SUMMARY · $(msg install_kitty_summary_full)"
    return 0
  fi
  summary "$SUMMARY · $(msg install_kitty_summary_keys)"
}

retire_iterm_profile() {
  grep -q '^iterm-profile|' "$MANIFEST" 2>/dev/null || return 0
  [ "$DRY" = 1 ] && return 0
  if [ -f "$ITERM_PROFILE" ] && same_file "$ROOT/terminals/iterm2.json" "$ITERM_PROFILE"; then
    rm -f "$ITERM_PROFILE"
    say "$(msg install_iterm_retired)"
  fi
  grep -v '^iterm-profile|' "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
}

configure_terminal() {
  rm -f "$CONFIG_DIR/kitty"
  retire_iterm_profile
  if uses_kitty; then
    configure_kitty
  else
    say "$(msg install_no_terminal_changes)"
    summary "$SUMMARY · $(msg install_other_summary)"
  fi
}

has_font() {
  local f
  for f in "$FONTS_DIR"/*[Jj]et[Bb]rains[Mm]ono* /Library/Fonts/*[Jj]et[Bb]rains[Mm]ono*; do
    [ -e "$f" ] && return 0
  done
  command -v fc-list >/dev/null && fc-list 2>/dev/null | grep -qi 'JetBrains Mono' && return 0
  return 1
}

install_font() {
  local zip
  if has_font; then
    say "$(msg install_font_present)"
  elif [ "$DEPS" = 0 ]; then
    say "$(msg install_font_no_deps)"
  elif [ "$DRY" = 1 ]; then
    say "$(msg install_dry_font "$FONTS_DIR")"
  elif ! command -v curl >/dev/null || ! command -v unzip >/dev/null; then
    warn "$(msg install_font_no_tools)"
  else
    zip="$(mktemp)"
    if curl -fsSL -o "$zip" https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip >> "$LOG" 2>&1 \
       && mkdir -p "$FONTS_DIR" && unzip -qo -j "$zip" 'fonts/ttf/*.ttf' -d "$FONTS_DIR" >> "$LOG" 2>&1; then
      if command -v fc-cache >/dev/null; then fc-cache -f "$FONTS_DIR" >> "$LOG" 2>&1; fi
      record font "$FONTS_DIR"
      say "$(msg install_font_done "$(short_path "$FONTS_DIR")")"
    else
      warn "$(msg install_font_failed)"
    fi
    rm -f "$zip"
  fi
}

install_dependencies() {
  local missing=() package setup versions=""
  step 1 "$(msg install_step_deps)"
  command -v tmux >/dev/null || missing+=(tmux)
  if [ ${#missing[@]} -eq 0 ]; then
    say "$(msg install_tmux_present)"
  elif [ "$DEPS" = 0 ]; then
    warn "$(msg install_missing_no_deps "${missing[*]}")"
  else
    if [ -n "$SUDO" ] && [ "$PKG_MANAGER" != brew ] && [ "$FANCY" = 1 ]; then
      stop_spin; sudo -v; spin
    fi
    [ "$PKG_MANAGER" = apt-get ] && { run ${SUDO:+"$SUDO"} apt-get update -qq || true; }
    for package in "${missing[@]}"; do
      case "$PKG_MANAGER" in
        brew)    setup=(brew install "$package") ;;
        apt-get) setup=(${SUDO:+"$SUDO"} apt-get install -y "$package") ;;
        dnf)     setup=(${SUDO:+"$SUDO"} dnf install -y "$package") ;;
        pacman)  setup=(${SUDO:+"$SUDO"} pacman -S --needed --noconfirm "$package") ;;
        zypper)  setup=(${SUDO:+"$SUDO"} zypper install -y "$package") ;;
        apk)     setup=(${SUDO:+"$SUDO"} apk add "$package") ;;
        *)       warn "$(msg install_unknown_pkg "${missing[*]}")"; break ;;
      esac
      run "${setup[@]}" || warn "$(msg install_pkg_failed "$package" "$PKG_MANAGER")"
    done
  fi
  if command -v tmux >/dev/null; then versions="tmux $(tmux -V | awk '{print $2}')"; fi
  summary "$versions"
  finish_step
}

install_code() {
  local origin_url
  if [ "$ROOT" = "$CODE" ]; then
    record code "$CODE"
  elif git -C "$ROOT" rev-parse >/dev/null 2>&1; then
    origin_url="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
    run rm -rf "$CODE"
    run mkdir -p "$(dirname "$CODE")"
    run git clone -q "$ROOT" "$CODE"
    [ -n "$origin_url" ] && run git -C "$CODE" remote set-url origin "$origin_url"
    run git -C "$CODE" checkout -q "$(git -C "$ROOT" rev-parse HEAD)"
    record code "$CODE"
    say "$(msg install_code_copy "$(short_path "$CODE")")"
  else
    warn "$(msg install_not_clone "$ROOT")"
  fi
}

remove_old_scripts() {
  local tipo target
  [ -f "$MANIFEST" ] && [ "$DRY" = 0 ] || return 0
  while IFS='|' read -r tipo target _; do
    [ "$tipo" = script ] || continue
    [ "$(basename "$target")" = work ] && continue
    rm -f "$target"
    grep -vxF "script|$target|" "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
    say "$(msg install_script_moved "$(basename "$target")" "$(short_path "$BIN_DIR")")"
  done < <(grep '^script|' "$MANIFEST" || true)
}

install_scripts() {
  local target="$BIN_DIR/work"
  step 2 "$(msg install_step_scripts)"
  run mkdir -p "$BIN_DIR"
  if [ -f "$target" ] && ! same_file "$ROOT/bin/work" "$target" && ! grep -qxF "script|$target|" "$MANIFEST" 2>/dev/null; then
    warn "$(msg install_work_exists)"
  else
    say "work"
    run install -m 755 "$ROOT/bin/work" "$target"
    record script "$target"
  fi
  case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) say "$(msg install_not_in_path "$BIN_DIR")" ;;
  esac
  install_code
  remove_old_scripts
  summary "$(msg install_scripts_summary "$(short_path "$BIN_DIR")")"
  finish_step
}

is_shipped_version() {
  local target="$1" path="$2" current c
  current="$(cksum < "$target")"
  git -C "$ROOT" rev-parse >/dev/null 2>&1 || return 1
  for c in $(git -C "$ROOT" log --format=%h -- "$path" 2>/dev/null); do
    [ "$(git -C "$ROOT" show "$c:$path" 2>/dev/null | cksum)" = "$current" ] && return 0
  done
  return 1
}

install_panels() {
  local old f panel name target
  for old in 10-maquina 00-comece-aqui 20-git; do
    f="$CONFIG_DIR/panels/$old"
    if [ -f "$f" ] && is_shipped_version "$f" "config/panels/$old"; then
      run rm -f "$f"
      say "$(msg install_old_panel "$old")"
    fi
  done
  for panel in "$ROOT"/config/panels/*; do
    name="$(basename "$panel")"
    target="$CONFIG_DIR/panels/$name"
    if [ ! -f "$target" ]; then
      run install -m 755 "$panel" "$target"
      say "$(msg install_panel "$name")"
    elif [ ! -x "$target" ]; then
      say "$(msg install_panel_off "$name")"
    elif same_file "$panel" "$target"; then
      say "$(msg install_panel "$name")"
    elif is_shipped_version "$target" "config/panels/$name"; then
      run install -m 755 "$panel" "$target"
      say "$(msg install_panel_updated "$name")"
    else
      say "$(msg install_panel_edited "$name")"
    fi
  done
}

localize_panel_window() {
  local file="$1" name
  name="$(msg window_panel)"
  grep -qE "^(painel|panel)\|[^|]*\|work-panel" "$file" || return 0
  grep -qE "^$name\|[^|]*\|work-panel" "$file" && return 0
  [ "$DRY" = 1 ] && return 0
  awk -v name="$name" -F'|' 'BEGIN { OFS = "|" } ($1 == "painel" || $1 == "panel") && $3 ~ /^work-panel/ { $1 = name } { print }' "$file" > "$file.tmp" \
    && cat "$file.tmp" > "$file" && rm -f "$file.tmp"
}

choose_clock() {
  local choice answer
  choice="${CLOCK_REQUESTED:-$(setting_get PANEL_CLOCK)}"
  if [ "$choice" != yes ] && [ "$choice" != no ]; then
    choice=no
    can_ask || return 0
    stop_spin
    if ! on_macos; then
      printf '  %s' "$(msg install_ask_clock)"
    elif command -v cargo >/dev/null; then
      printf '%s' "$(msg install_ask_clock_mac)" | sed 's/^/  /'
    else
      printf '%s' "$(msg install_ask_clock_mac_no_rust)" | sed 's/^/  /'
    fi
    read -r answer || answer=n
    spin
    case "$answer" in s|S|y|Y) choice=yes ;; esac
  fi
  save_choice PANEL_CLOCK "$choice"
  [ "$choice" = yes ] && install_tclock
  return 0
}

install_tclock() {
  local arch tmp binary
  if command -v tclock >/dev/null; then
    say "$(msg install_clock_present)"
    return 0
  fi
  if [ "$DEPS" = 0 ]; then
    warn "$(msg install_clock_no_deps)"
    return 0
  fi
  if [ "$DRY" = 1 ]; then
    say "$(msg install_dry_clock)"
    return 0
  fi
  if on_macos; then
    if ! command -v cargo >/dev/null; then
      warn "$(msg install_clock_needs_rust)"
      return 0
    fi
    say "$(msg install_clock_compiling)"
    if cargo install --git "$TCLOCK_REPO" clock-tui --root "$HOME/.local" >> "$LOG" 2>&1; then
      record tclock-cargo "$BIN_DIR/tclock"
      say "$(msg install_clock_installed "$(short_path "$BIN_DIR/tclock")")"
    else
      warn "$(msg install_clock_failed "$TCLOCK_REPO")"
    fi
    return 0
  fi
  case "$(uname -m)" in
    x86_64|amd64) arch=x86_64 ;;
    aarch64|arm64) arch=aarch64 ;;
    *) warn "$(msg install_clock_failed "$TCLOCK_REPO")"; return 0 ;;
  esac
  say "$(msg install_clock_downloading)"
  tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/tclock.tar.gz" "$TCLOCK_REPO/releases/latest/download/clock-tui-linux-$arch.tar.gz" 2>> "$LOG" \
     && curl -fsSL -o "$tmp/tclock.sha256" "$TCLOCK_REPO/releases/latest/download/clock-tui-linux-$arch.tar.gz.sha256" 2>> "$LOG" \
     && [ "$(awk '{print $1}' "$tmp/tclock.sha256")" = "$( (sha256sum "$tmp/tclock.tar.gz" 2>/dev/null || shasum -a 256 "$tmp/tclock.tar.gz") | awk '{print $1}')" ] \
     && tar -xzf "$tmp/tclock.tar.gz" -C "$tmp" >> "$LOG" 2>&1 \
     && binary="$(find "$tmp" -type f -name tclock | head -1)" && [ -n "$binary" ]; then
    mkdir -p "$BIN_DIR"
    install -m 755 "$binary" "$BIN_DIR/tclock"
    record tclock "$BIN_DIR/tclock"
    say "$(msg install_clock_installed "$(short_path "$BIN_DIR/tclock")")"
  else
    warn "$(msg install_clock_failed "$TCLOCK_REPO")"
  fi
  rm -rf "$tmp"
}

install_config() {
  step 3 "$(msg install_step_config)"
  run mkdir -p "$CONFIG_DIR/panels"
  if [ -f "$CONFIG_DIR/projects.conf" ]; then
    localize_panel_window "$CONFIG_DIR/projects.conf"
    say "$(msg install_projects_exists)"
  else
    say "$(msg install_projects_hint)"
  fi
  install_panels
  choose_clock
  if [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/git-review" ]; then
    run rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/git-review"
    say "$(msg install_git_review_removed)"
  fi
  summary "$(short_path "$CONFIG_DIR")"
  finish_step
}

fill_messages() {
  local text marker key
  text="$(cat)"
  for marker in $(printf '%s\n' "$text" | grep -o '{{msg:[a-z0-9_]*}}' | sort -u); do
    key="${marker#??msg:}"
    key="${key%??}"
    text="$(printf '%s\n' "$text" | WD_MARKER="$marker" WD_VALUE="$(msg "$key")" awk '
      BEGIN {
        marker = ENVIRON["WD_MARKER"]; value = ENVIRON["WD_VALUE"]
        gsub(/#/, "##", value); gsub(/"/, "\\\"", value)
      }
      {
        line = $0; out = ""
        while ((i = index(line, marker)) > 0) { out = out substr(line, 1, i - 1) value; line = substr(line, i + length(marker)) }
        print out line
      }')"
  done
  printf '%s\n' "$text"
}

configure_tmux_and_terminal() {
  step 4 "$(msg install_step_tmux)"
  write_block "$HOME/.tmux.conf" \
    "$(sed '$d' "$ROOT/config/tmux.conf" | sed '/^# The theme is appended here/d' | fill_messages; cat "$ROOT/themes/$THEME.tmux"; echo "run-shell -b \"$BIN_DIR/work _settings\""; echo '# <<< workdeck <<<')"
  say "$(msg install_tmux_done)"
  summary "$(msg install_tmux_summary)"
  choose_terminal
  choose_visual
  configure_terminal
  finish_step
}

has_custom_zsh() {
  [ -d "$HOME/.oh-my-zsh" ] && ! grep -q '^omz|' "$MANIFEST" 2>/dev/null && return 0
  [ -f "$HOME/.zshrc" ] && without_block "$HOME/.zshrc" \
    | grep -qE 'zsh-autosuggestions|fast-syntax-highlighting|zsh-syntax-highlighting|zinit|oh-my-zsh|starship|powerlevel10k|p10k|spaceship|pure' && return 0
  return 1
}

install_omz_zinit() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone -q --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" >> "$LOG" 2>&1 || return 1
    record omz "$HOME/.oh-my-zsh"
  fi
  if [ ! -f "$ZINIT_DIR/zinit.zsh" ]; then
    mkdir -p "$(dirname "$ZINIT_DIR")"
    git clone -q --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_DIR" >> "$LOG" 2>&1 || return 1
    record zinit "$(dirname "$ZINIT_DIR")"
  fi
  [ -d "$ZSH_PLUGINS" ] && rm -rf "$ZSH_PLUGINS"
  return 0
}

setup_zsh() {
  local choice previous r zsh_bin
  choice="$(setting_get ZSH)"
  previous="$choice"
  [ "$choice" = no ] && [ "$WANT_ZSH" = 0 ] && return 0
  if [ "$choice" != yes ]; then
    if has_custom_zsh; then
      say "$(msg install_zsh_custom)"
      return 0
    fi
    if [ "$WANT_ZSH" = 0 ] && can_ask; then
      stop_spin
      printf '  %s' "$(msg install_ask_zsh)"
      read -r r || r=s
      spin
      case "$r" in ""|s|S|y|Y) ;; *) save_choice ZSH no; return 0 ;; esac
    fi
  fi
  [ "$DRY" = 1 ] && { say "$(msg install_dry_zsh)"; return 0; }
  if ! command -v zsh >/dev/null; then
    if [ "$OS_NAME" != macOS ] && [ "$DEPS" = 1 ] && [ -n "$PKG_MANAGER" ]; then
      stop_spin
      case "$PKG_MANAGER" in
        apt-get) ${SUDO:+"$SUDO"} apt-get install -y zsh ;;
        dnf) ${SUDO:+"$SUDO"} dnf install -y zsh ;;
        pacman) ${SUDO:+"$SUDO"} pacman -S --needed --noconfirm zsh ;;
        zypper) ${SUDO:+"$SUDO"} zypper install -y zsh ;;
        apk) ${SUDO:+"$SUDO"} apk add zsh ;;
      esac >> "$LOG" 2>&1 || true
      spin
    fi
    command -v zsh >/dev/null || { warn "$(msg install_zsh_failed)"; return 0; }
  fi
  zsh_bin="$(command -v zsh)"
  if [ "$(basename "${SHELL:-}")" != zsh ]; then
    stop_spin
    printf '  %s' "$(msg install_ask_chsh)"
    read -r r </dev/tty 2>/dev/null || r=n
    spin
    case "${r:-s}" in
      s|S|y|Y)
        stop_spin
        grep -qx "$zsh_bin" /etc/shells 2>/dev/null || echo "$zsh_bin" | ${SUDO:+"$SUDO"} tee -a /etc/shells >/dev/null
        if chsh -s "$zsh_bin" </dev/tty; then SHELL="$zsh_bin"; RESTART_SHELL=1; else warn "$(msg install_chsh_failed "$zsh_bin")"; fi
        spin ;;
    esac
  fi
  if install_omz_zinit; then
    save_choice ZSH yes
    ZSH_SUMMARY="$(msg install_zsh_summary)"
    [ "$previous" = yes ] || RESTART_SHELL=1
  else
    warn "$(msg install_omz_failed)"
  fi
}

configure_shell() {
  local rc=""
  step 5 "$(msg install_step_shell)"
  setup_zsh
  case "$(basename "${SHELL:-/bin/bash}")" in
    zsh)  rc="$HOME/.zshrc" ;;
    bash) if [ "$OS_NAME" = "macOS" ]; then rc="$HOME/.bash_profile"; else rc="$HOME/.bashrc"; fi ;;
  esac
  if [ -n "$rc" ]; then
    write_block "$rc" "$(cat "$ROOT/config/shell-snippet.sh")"
    SHELL_CHANGED="$BLOCK_CHANGED"
    if [ "$(setting_get ZSH)" = yes ] && [ "$DRY" = 0 ] && command -v zsh >/dev/null; then
      zsh -i -c exit </dev/null >> "$LOG" 2>&1 || true
    fi
    say "$(basename "$rc")"
    summary "$(short_path "$rc")${ZSH_SUMMARY:+ · $ZSH_SUMMARY}"
  else
    warn "$(msg install_unknown_shell "$SHELL" "$ROOT/config/shell-snippet.sh")"
  fi
  finish_step
}

configure_agent() {
  local current_agent="" found=() c
  step 6 "$(msg install_step_agent)"
  current_agent="$(setting_get AGENT_CMD)"
  if [ -n "$AGENT" ]; then
    run "$ROOT/bin/workdeck-agent" --set "$AGENT" >/dev/null && say "$(msg install_agent "$AGENT")"
    summary "$AGENT"
  elif [ -n "$current_agent" ]; then
    say "$(msg install_agent_set "$current_agent")"
    summary "$current_agent"
  else
    for c in $KNOWN_AGENTS; do
      command -v "$c" >/dev/null && found+=("$c")
    done
    if [ ${#found[@]} -eq 0 ]; then
      say "$(msg install_no_agent)"
      summary "$(msg install_no_agent_summary)"
    else
      run "$ROOT/bin/workdeck-agent" --set "${found[0]}" >/dev/null && say "$(msg install_agent "${found[0]}")"
      [ ${#found[@]} -eq 1 ] || say "$(msg install_agent_others "${found[*]:1}")"
      summary "$(msg install_agent_detected_summary "${found[0]}")"
    fi
  fi
  finish_step
}

enable_integration() {
  local name="$1" file_path="$ROOT/integrations/$1.sh"
  if [ ! -f "$file_path" ]; then
    warn "$(msg install_unknown_integration "$name")"
    return 0
  fi
  (
    . "$file_path"
    title="$(describe | head -1)"
    if is_installed 2>/dev/null; then
      say "$(msg install_integration_present "$title")"
      if declare -F usage >/dev/null; then echo; usage | sed 's/^/    /'; fi
      exit 0
    fi
    echo
    describe | sed 's/^/    /'
    echo
    [ "$DRY" = 1 ] && { say "$(msg install_dry_integration "$title")"; exit 0; }
    setup | sed 's/^/    /'
    if declare -F usage >/dev/null; then echo; usage | sed 's/^/    /'; fi
  )
}

configure_integrations() {
  local requested=() name
  step 7 "$(msg install_step_integrations)"
  if [ -z "$WITH" ]; then
    if setting_has INTEGRATIONS && [ "$(setting_get INTEGRATIONS)" != none ]; then
      say "$(msg install_integrations_before "$(setting_get INTEGRATIONS)")"
      summary "$(setting_get INTEGRATIONS)"
    else
      say "$(msg install_integrations_none)"
      summary "$(msg install_integrations_none_summary)"
    fi
  else
    stop_spin
    summary "$WITH"
    IFS=',' read -r -a requested <<< "$WITH"
    for name in "${requested[@]}"; do enable_integration "$name"; done
  fi
  finish_step
}

choice_status() {
  setting_has "$1" && return 0
  msg install_not_saved
}

show_choices() {
  local visual
  visual="$(msg install_no)"
  printf '\n  %s\n' "$(msg install_choices)"
  printf '       %-9s %s%s\n' "$(msg install_choice_language)" "$(language_name "$LANGUAGE")" "$(choice_status LANGUAGE)"
  printf '                 %s\n' "$(msg install_choice_language_hint)"
  printf '       terminal  %s%s\n' "$(chosen_terminal_name)" "$(choice_status TERMINAL)"
  printf '                 %s\n' "$(msg install_choice_terminal_hint)"
  terminal_has_visual || return 0
  [ "$VISUAL" = yes ] && visual="$(msg install_yes)"
  printf '       visual    %s%s\n' "$visual" "$(choice_status VISUAL)"
  printf '                 %s\n' "$(msg install_choice_visual_hint)"
}

finish() {
  local open_hint="" new_window=0
  if [ "$RELOAD" = 1 ] && command -v tmux >/dev/null && tmux info >/dev/null 2>&1; then
    run tmux source-file "$HOME/.tmux.conf" && say "$(msg install_tmux_reloaded)"
  fi
  if [ -n "$UPDATING" ]; then
    if [ "$RESTART_SHELL" = 1 ]; then
      printf '\n  %s●%s %s\n' "$yellow" "$reset" "$(msg install_restart_terminal "$(current_terminal_name)")"
    fi
    exit 0
  fi
  if [ "$FANCY" = 1 ]; then
    echo
    LOGO_INDENT="  " print_logo "" "" "${bold}workdeck${reset} ${dim}${VERSION}${reset}" "${dim}$(msg panel_tagline)${reset}" "" "${green}$(msg install_done_fancy "$SECONDS")${reset}" "" "" ""
  else
    msgln install_done
  fi
  [ "$SHELL_CHANGED" = 1 ] && new_window=1
  case ":$PATH:" in *":$BIN_DIR:"*) ;; *) new_window=1 ;; esac
  if in_kitty && { [ "$RESTART_SHELL" = 1 ] || [ "$new_window" = 1 ] || [ "$KITTY_CHANGED" = 1 ]; }; then
    if [ "$RESTART_SHELL" = 1 ]; then
      open_hint="$(next_step "$(msg install_open_kitty_restart)" "$(msg install_open_kitty_restart_hint)")"
    else
      open_hint="$(next_step "$(msg install_open_kitty_restart)" "$(msg install_open_kitty_reload_hint)")"
    fi
  elif uses_kitty && ! in_kitty && kitty_installed && [ "$VISUAL" = yes ]; then
    open_hint="$(next_step "$(msg install_open_kitty)" "$(msg install_open_kitty_visual_hint)")"
  elif uses_kitty && ! in_kitty && kitty_installed; then
    open_hint="$(next_step "$(msg install_open_kitty)" "$(msg install_open_kitty_hint)")"
  elif [ "$RESTART_SHELL" = 1 ] && in_warp; then
    open_hint="$(next_step "$(msg install_open_warp_restart)" "$(msg install_open_terminal_restart_hint)")"
  elif [ "$RESTART_SHELL" = 1 ]; then
    open_hint="$(next_step "$(msg install_open_terminal_restart)" "$(msg install_open_terminal_restart_hint)")"
  elif [ "$new_window" = 1 ]; then
    open_hint="$(next_step "$(msg install_open_new_window)" "$(msg install_open_new_window_hint)")"
  fi
  printf '\n  %s\n' "$(msg install_now)"
  [ -z "$open_hint" ] || printf '       %s\n' "$open_hint"
  printf '       %s\n\n' "$(next_step work "$(msg install_work_hint)" plain)"
  printf '%s\n' "$(msg install_navigation "$(menu_key)")"
  if [ "$QUICK_ACCESS" = 1 ]; then
    printf '\n  %s\n' "$(msg install_quick_access_todo)"
    if on_macos; then printf '%s\n' "$(msg install_quick_access_steps)"; else printf '%s\n' "$(msg install_quick_access_steps_linux)"; fi
  fi
  show_choices
}

terminal_modifier() {
  if uses_kitty && on_macos; then echo "⌘"
  elif uses_kitty; then echo "Ctrl+Shift+"
  fi
}

menu_key() {
  local mod
  mod="$(terminal_modifier)"
  if [ -n "$mod" ]; then echo "${mod}H"; else echo "Ctrl+b h"; fi
}

next_step() {
  local label="$1" width
  width=$(printf '%s' "$label" | LC_ALL=C tr -d '\200-\277' | wc -c)
  if [ "${3:-}" = plain ]; then
    printf '%s%*s %s%s%s' "$label" $((30 - width)) "" "$dim" "$2" "$reset"
  else
    printf '%s%s%s%*s %s%s%s' "$bold" "$label" "$reset" $((30 - width)) "" "$dim" "$2" "$reset"
  fi
}

refuse_windows() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*|*_NT*|Windows*)
      msgln install_windows
      exit 1 ;;
  esac
}

main() {
  VERSION="$(git -C "$ROOT" describe --tags --abbrev=0 2>/dev/null || true)"
  refuse_windows
  parse_options "$@"
  setup_output
  choose_language
  [ "$DRY" = 1 ] || { settings_ensure_header; migrate_legacy_config; }
  save_choice LANGUAGE "$LANGUAGE"
  choose_theme
  detect_system
  show_header
  install_dependencies
  install_scripts
  install_config
  configure_tmux_and_terminal
  configure_shell
  configure_agent
  configure_integrations
  [ "$DRY" = 1 ] || settings_ensure_template
  finish
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
