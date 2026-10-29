WORKDECK_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/workdeck"
WORKDECK_CODE="${XDG_DATA_HOME:-$HOME/.local/share}/workdeck"
WORKDECK_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/workdeck"
WORKDECK_BIN="$HOME/.local/bin"
WORKDECK_SETTINGS="$WORKDECK_CONFIG/settings.conf"
KNOWN_AGENTS="claude codex copilot aider gemini opencode cursor-agent crush goose q"

short_path() {
  case "$1" in
    "$HOME"/*) printf '%s/%s\n' '~' "${1#"$HOME"/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

same_file() { [ "$(cksum < "$1")" = "$(cksum < "$2")" ]; }

has_block() { grep -q '^# >>> workdeck >>>$' "$1" 2>/dev/null; }

without_block() { awk '/^# >>> workdeck >>>$/{s=1} !s{print} /^# <<< workdeck <<<$/{s=0}' "$1"; }

# settings.conf holds lines like KEY="value". Only that exact shape counts:
# commented lines and lines such as KEY=value or KEY = "value" are ignored, and
# the first valid line of a key wins. The file is never sourced.
SETTING_LINE_END='"$'

# grep -a: GNU grep treats a file with invalid UTF-8 (say, a comment saved by a
# Latin-1 editor) as binary and would print "Binary file matches" instead of the line.
setting_has() { grep -aq "^$1=\".*$SETTING_LINE_END" "$WORKDECK_SETTINGS" 2>/dev/null; }

setting_get() {
  local line value
  if ! line="$(grep -a -m1 "^$1=\".*$SETTING_LINE_END" "$WORKDECK_SETTINGS" 2>/dev/null)"; then
    printf '%s\n' "${2:-}"
    return 0
  fi
  value="${line#*=\"}"
  value="${value%\"}"
  printf '%s\n' "$value" | awk '{
    out = ""
    for (i = 1; i <= length($0); i++) {
      c = substr($0, i, 1)
      if (c == "\\" && i < length($0)) { i++; c = substr($0, i, 1) }
      out = out c
    }
    print out
  }'
}

# Replaces the first valid line of the key, or appends one when there is none.
setting_set() {
  local newline escaped tmp
  newline="$(printf '\n.')"
  newline="${newline%.}"
  case "$2" in *"$newline"*) return 1 ;; esac
  escaped="$(printf '%s' "$2" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
  mkdir -p "$(dirname "$WORKDECK_SETTINGS")"
  if setting_has "$1"; then
    tmp="$WORKDECK_SETTINGS.tmp"
    if SETTING_KEY="$1" SETTING_NEW="$1=\"$escaped\"" awk '
      BEGIN { key = ENVIRON["SETTING_KEY"]; new = ENVIRON["SETTING_NEW"] }
      !done && index($0, key "=\"") == 1 && length($0) >= length(key) + 3 && substr($0, length($0)) == "\"" { print new; done = 1; next }
      { print }' "$WORKDECK_SETTINGS" > "$tmp"; then
      settings_commit "$tmp"
    else
      rm -f "$tmp"
      return 1
    fi
    return
  fi
  settings_end_with_newline
  printf '%s="%s"\n' "$1" "$escaped" >> "$WORKDECK_SETTINGS"
}

# Writes through the path instead of renaming over it, so a settings.conf that is
# a symlink into a dotfiles repo stays a symlink and keeps its mode.
settings_commit() {
  local tmp="$1" status=0
  cat "$tmp" > "$WORKDECK_SETTINGS" || status=1
  rm -f "$tmp"
  return "$status"
}

settings_end_with_newline() {
  if [ -s "$WORKDECK_SETTINGS" ] && [ "$(tail -c 1 "$WORKDECK_SETTINGS" | wc -l)" -eq 0 ]; then
    printf '\n' >> "$WORKDECK_SETTINGS"
  fi
}

# Creates the file with its explanatory header, so the header is always the
# first thing in it, whoever writes the first key.
settings_ensure_header() {
  [ -f "$WORKDECK_SETTINGS" ] && return 0
  mkdir -p "$(dirname "$WORKDECK_SETTINGS")"
  printf '%s\n' \
    '# Configurações do workdeck. Cada linha é CHAVE="valor"; linhas com # no começo são comentários.' \
    '# A instalação lembra aqui as suas escolhas, e você pode editar à mão.' > "$WORKDECK_SETTINGS"
}

# Adds a commented example for every optional key the file does not mention
# yet, active or commented, so an existing user can find the option.
settings_ensure_template() {
  settings_ensure_header
  if ! grep -aqE '^#?ACTIVE_PANE=' "$WORKDECK_SETTINGS"; then
    settings_end_with_newline
    printf '\n%s\n%s\n%s\n' \
      '# Destaque do painel ativo: "none" (padrão, o visual do tema) ou "line"' \
      '# (traço fino no topo do painel ativo). Ctrl+b r aplica.' \
      '#ACTIVE_PANE="line"' >> "$WORKDECK_SETTINGS"
  fi
}

setting_unset() {
  local tmp="$WORKDECK_SETTINGS.tmp"
  setting_has "$1" || return 0
  if SETTING_KEY="$1" awk '
    BEGIN { key = ENVIRON["SETTING_KEY"] }
    !done && index($0, key "=\"") == 1 && length($0) >= length(key) + 3 && substr($0, length($0)) == "\"" { done = 1; next }
    { print }' "$WORKDECK_SETTINGS" > "$tmp"; then
    settings_commit "$tmp"
  else
    rm -f "$tmp"
    return 1
  fi
}

# Old choice files hold a single word; agent.conf and update.conf were shell
# files that older versions sourced, so they are read once, in a subshell.
sourced_choice() {
  ( unset "$2"; [ -f "$1" ] && . "$1" >/dev/null 2>&1; eval "printf '%s' \"\${$2:-}\"" )
}

fold_choice() {
  local key="$1" value="$2" old_file="$3"
  [ -f "$old_file" ] || return 0
  if [ -n "$value" ] && ! setting_has "$key"; then
    setting_set "$key" "$value"
  fi
  rm -f "$old_file"
}

migrate_choice_files() {
  local dir="$WORKDECK_CONFIG" pair file
  [ -d "$dir" ] || return 0
  for pair in terminal:TERMINAL theme:THEME visual:VISUAL integrations:INTEGRATIONS zsh:ZSH; do
    file="$dir/${pair%%:*}"
    [ -f "$file" ] && fold_choice "${pair##*:}" "$(cat "$file")" "$file"
  done
  fold_choice AGENT_CMD "$(sourced_choice "$dir/agent.conf" AGENT_CMD)" "$dir/agent.conf"
  fold_choice NOTIFY "$(sourced_choice "$dir/update.conf" NOTIFY)" "$dir/update.conf"
  return 0
}

migrate_legacy_config() {
  local dir="$WORKDECK_CONFIG" value
  [ -d "$dir" ] || return 0
  if [ -f "$dir/tema" ]; then
    [ -f "$dir/theme" ] || mv "$dir/tema" "$dir/theme"
    rm -f "$dir/tema"
  fi
  if [ -f "$dir/integracoes" ]; then
    if [ ! -f "$dir/integrations" ]; then
      value="$(cat "$dir/integracoes")"
      [ "$value" = nenhuma ] && value=none
      printf '%s\n' "$value" > "$dir/integrations"
    fi
    rm -f "$dir/integracoes"
  fi
  if [ -f "$dir/zsh" ]; then
    case "$(cat "$dir/zsh")" in
      sim) echo yes > "$dir/zsh" ;;
      nao) echo no > "$dir/zsh" ;;
    esac
  fi
  if [ -f "$dir/atualizacao.conf" ]; then
    if [ ! -f "$dir/update.conf" ]; then
      sed 's/^AVISO=/NOTIFY=/' "$dir/atualizacao.conf" > "$dir/update.conf"
    fi
    rm -f "$dir/atualizacao.conf"
  fi
  if [ -f "$dir/.install-manifest" ] && grep -qE '^(bloco|codigo|fonte)\||\|:criado$' "$dir/.install-manifest"; then
    sed -e 's/^bloco|/block|/' -e 's/^codigo|/code|/' -e 's/^fonte|/font|/' -e 's/|:criado$/|:created/' \
      "$dir/.install-manifest" > "$dir/.install-manifest.tmp" \
      && mv "$dir/.install-manifest.tmp" "$dir/.install-manifest"
  fi
  rm -f "$WORKDECK_CACHE/atualizacao" "$WORKDECK_CACHE/pedido-de-review.md"
  migrate_choice_files
  return 0
}
