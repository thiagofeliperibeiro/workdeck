# Subscription usage of the agents, drawn as bars in the tmux status bar.
#
# Claude Code passes its limits only to its statusLine command, which workdeck
# points at bin/workdeck-statusline; that saves them in $USAGE_DIR/claude.
# Codex writes them to its session logs, read here. Each source gives lines of
# "label percent resets_at", with resets_at in Unix seconds.

USAGE_DIR="$WORKDECK_CACHE/usage"
USAGE_AGENTS="claude codex"
CLAUDE_PREVIOUS_STATUSLINE="$WORKDECK_CONFIG/claude-statusline.json"

# usage_number FLAT_OBJECT FIELD: the number in "FIELD":N, or nothing.
usage_number() {
  printf '%s' "$1" | sed -n "s/.*\"$2\":\([0-9][0-9.eE+-]*\).*/\1/p"
}

# usage_object FLAT_JSON NAME: the text inside {"NAME":{...}}, which holds no
# nested object for the fields read here.
usage_object() {
  case "$1" in *"\"$2\":{"*) ;; *) return 1 ;; esac
  local rest="${1#*\"$2\":\{}"
  printf '%s\n' "${rest%%\}*}"
}

usage_save_claude() {
  local flat limits name label part pct reset out="" tmp
  flat="$(printf '%s' "$1" | tr -d ' \t\r\n')"
  case "$flat" in *'"rate_limits":{'*) ;; *) return 0 ;; esac
  limits="${flat#*\"rate_limits\":\{}"
  for name in five_hour seven_day; do
    case "$name" in five_hour) label=5h ;; *) label=7d ;; esac
    part="$(usage_object "$limits" "$name")" || continue
    pct="$(usage_number "$part" used_percentage)"
    reset="$(usage_number "$part" resets_at)"
    [ -n "$pct" ] && [ -n "$reset" ] || continue
    out="$out$label $pct ${reset%.*}"$'\n'
  done
  [ -n "$out" ] || return 0
  mkdir -p "$USAGE_DIR" 2>/dev/null || return 0
  tmp="$USAGE_DIR/claude.$$"
  printf '%s' "$out" > "$tmp" && mv -f "$tmp" "$USAGE_DIR/claude"
  rm -f "$tmp"
  return 0
}

usage_claude() {
  [ -f "$USAGE_DIR/claude" ] && cat "$USAGE_DIR/claude"
  return 0
}

# The newest Codex session logs of the last week, newest first.
usage_codex_logs() {
  local dir="${CODEX_HOME:-$HOME/.codex}/sessions"
  [ -d "$dir" ] || return 0
  find "$dir" -name 'rollout-*.jsonl' -mtime -8 -exec ls -t {} + 2>/dev/null | head -5
  return 0
}

# usage_codex_parse LINE LOG: the windows of one token_count event. Older Codex
# versions give resets_in_seconds instead of resets_at; the log's time stands
# in for the event's.
usage_codex_parse() {
  local flat limits slot part pct minutes reset seconds label
  flat="$(printf '%s' "$1" | tr -d ' \t\r')"
  limits="${flat#*\"rate_limits\":\{}"
  for slot in primary secondary; do
    part="$(usage_object "$limits" "$slot")" || continue
    pct="$(usage_number "$part" used_percent)"
    [ -n "$pct" ] || continue
    minutes="$(usage_number "$part" window_minutes)"
    reset="$(usage_number "$part" resets_at)"
    if [ -z "$reset" ]; then
      seconds="$(usage_number "$part" resets_in_seconds)"
      [ -n "$seconds" ] || continue
      reset=$(( $(date -r "$2" +%s) + ${seconds%.*} ))
    fi
    minutes="${minutes%.*}"
    if [ -z "$minutes" ]; then
      if [ "$slot" = primary ]; then label=5h; else label=7d; fi
    elif [ "$minutes" -lt 1440 ]; then label="$((minutes / 60))h"
    else label="$((minutes / 1440))d"
    fi
    printf '%s %s %s\n' "$label" "$pct" "${reset%.*}"
  done
  return 0
}

# Reads the logs only when one is newer than the last answer.
usage_codex() {
  local logs log line out="" cache="$USAGE_DIR/codex"
  logs="$(usage_codex_logs)"
  [ -n "$logs" ] || return 0
  if [ -f "$cache" ] && [ "$cache" -nt "$(printf '%s\n' "$logs" | head -1)" ]; then
    cat "$cache"
    return 0
  fi
  while IFS= read -r log; do
    line="$(grep '"rate_limits":{' "$log" 2>/dev/null | grep '"limit_id":"codex"' | tail -n 1)"
    [ -n "$line" ] || line="$(grep '"rate_limits":{' "$log" 2>/dev/null | tail -n 1)"
    [ -n "$line" ] || continue
    out="$(usage_codex_parse "$line" "$log")"
    [ -n "$out" ] && break
  done <<< "$logs"
  mkdir -p "$USAGE_DIR" 2>/dev/null && printf '%s\n' "$out" > "$cache.$$" && mv -f "$cache.$$" "$cache"
  [ -z "$out" ] || printf '%s\n' "$out"
  return 0
}

# The time of the newest data of an agent, for picking one when the window
# has no agent running.
usage_source() {
  case "$1" in
    claude) printf '%s\n' "$USAGE_DIR/claude" ;;
    codex) usage_codex_logs | head -1 ;;
  esac
}

# The agent running in a pane of the window, if workdeck can show its usage.
usage_window_agent() {
  local processes tty
  [ -n "$1" ] || return 0
  processes="$(ps -A -o tty=,comm= 2>/dev/null)"
  for tty in $(tmux list-panes -t "$1" -F '#{pane_tty}' 2>/dev/null); do
    printf '%s\n' "$processes" | awk -v t="${tty#/dev/}" -v known=" $USAGE_AGENTS " '
      $1 == t { n = split($2, part, "/"); if (index(known, " " part[n] " ")) { print part[n]; found = 1; exit } }
      END { exit !found }' && return 0
  done
  return 0
}

usage_pick_agent() {
  local agent newest="" file best=""
  agent="$(usage_window_agent "${1:-}")"
  [ -z "$agent" ] || { printf '%s\n' "$agent"; return 0; }
  for agent in $USAGE_AGENTS; do
    file="$(usage_source "$agent")"
    [ -n "$file" ] && [ -f "$file" ] || continue
    if [ -z "$newest" ] || [ "$file" -nt "$newest" ]; then newest="$file"; best="$agent"; fi
  done
  [ -z "$best" ] || printf '%s\n' "$best"
  return 0
}

# usage_render AGENT NOW ACCENT DIM MUTED: one tmux status segment from the
# "label percent resets_at" lines on stdin. A window whose reset has passed is
# left out, because its number no longer holds.
usage_render() {
  awk -v agent="$1" -v now="$2" -v accent="$3" -v dim="$4" -v muted="$5" '
    $3 + 0 > now + 0 {
      pct = int($2 + 0.5); if (pct < 0) pct = 0; if (pct > 100) pct = 100
      filled = int((pct + 10) / 20); bar = ""; rest = ""
      for (i = 0; i < 5; i++) if (i < filled) bar = bar "▰"; else rest = rest "▱"
      color = pct >= 90 ? "red" : accent
      out = out (out == "" ? "" : " #[fg=" muted "]· ") "#[fg=" muted "]" $1 " #[fg=" color "]" bar "#[fg=" dim "]" rest " #[fg=" muted "]" pct "%"
    }
    END { if (out != "") printf "#[fg=%s]%s %s #[fg=%s]· ", muted, agent, out, muted }'
}

# work _usage WINDOW: the usage segment of the status bar, or nothing.
usage_status() {
  local agent lines colors accent dim muted
  agent="$(usage_pick_agent "${1:-}")"
  [ -n "$agent" ] || return 0
  lines="$("usage_$agent")"
  [ -n "$lines" ] || return 0
  colors="$(tmux display -p '#{@wd_accent}|#{@wd_dim}|#{@wd_muted}' 2>/dev/null)"
  IFS='|' read -r accent dim muted <<< "$colors"
  printf '%s\n' "$lines" | usage_render "$agent" "$(date +%s)" "${accent:-default}" "${dim:-default}" "${muted:-default}"
  return 0
}
