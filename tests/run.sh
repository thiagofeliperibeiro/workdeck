#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$ROOT/tests/lib.sh"

command -v tmux >/dev/null || { echo "the tests need tmux"; exit 1; }
command -v git >/dev/null || { echo "the tests need git"; exit 1; }

usage() {
  echo "usage: tests/run.sh [--changed] [--jobs N] [name filter]"
  echo "  --changed   only the test files related to the files changed since HEAD"
  echo "  --jobs N    tests running at the same time (default: number of CPUs, up to 8)"
}

cpus() { getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2; }

filter=""
changed=0
jobs="${WORKDECK_TEST_JOBS:-$(cpus)}"
[ "$jobs" -le 8 ] || jobs=8
while [ $# -gt 0 ]; do
  case "$1" in
    --changed) changed=1; shift ;;
    --jobs) jobs="${2:?--jobs needs a number}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) filter="$1"; shift ;;
  esac
done

changed_files() {
  { git -C "$ROOT" diff --name-only HEAD; git -C "$ROOT" ls-files --others --exclude-standard; } | sort -u
}

test_files_for() {
  case "$1" in
    tests/lib.sh|tests/run.sh|lib/*|lang/*) echo all ;;
    tests/*.test.sh) basename "$1" .test.sh ;;
    install.sh|get.sh|instalar.sh) printf '%s\n' install terminal kitty theme settings uninstall update lang ;;
    uninstall.sh) printf '%s\n' uninstall terminal ;;
    bin/workdeck-agent) printf '%s\n' install agents ;;
    bin/workdeck-statusline) echo usage ;;
    bin/work-panel|config/panels/*) printf '%s\n' panels lang ;;
    bin/work) printf '%s\n' session panes split agents keys update lang ;;
    config/tmux.conf) printf '%s\n' keys panes split agents session ;;
    config/shell-snippet.sh) echo install ;;
    terminals/*) printf '%s\n' terminal kitty keys ;;
    themes/*) echo theme ;;
  esac
}

selected_files() {
  local f name
  if [ "$changed" = 0 ]; then
    ls "$ROOT"/tests/*.test.sh
    return 0
  fi
  for name in $(changed_files | while IFS= read -r f; do test_files_for "$f"; done | sort -u); do
    if [ "$name" = all ]; then ls "$ROOT"/tests/*.test.sh; return 0; fi
    [ -f "$ROOT/tests/$name.test.sh" ] && echo "$ROOT/tests/$name.test.sh"
  done
  return 0
}

writes_to_repo() {
  awk -v t="$2" '$0 ~ "^" t "\\(\\)" { inside = 1; next } inside && /^}/ { exit } inside && /git -C "\$REPO".*(commit|tag)/ { found = 1 } END { exit !found }' "$1"
}

setup_repo
trap 'rm -rf "$TEST_TMP"' EXIT

parallel=()
serial=()
for file in $(selected_files); do
  while IFS= read -r test_name; do
    if [ -n "$filter" ]; then
      case "$test_name" in *"$filter"*) ;; *) continue ;; esac
    fi
    if writes_to_repo "$file" "$test_name"; then
      serial+=("$file|$test_name")
    else
      parallel+=("$file|$test_name")
    fi
  done < <(grep -oE '^test_[a-z0-9_]+' "$file")
done

run_one() {
  local file="${1%%|*}" test_name="${1#*|}"
  if ( . "$file"; setup_home "$test_name"; trap cleanup_tmux EXIT; "$test_name" ) < /dev/null > "$TEST_TMP/$test_name.log" 2>&1; then
    echo ok > "$TEST_TMP/$test_name.status"
  else
    echo fail > "$TEST_TMP/$test_name.status"
  fi
}

running=()
for entry in ${parallel[@]+"${parallel[@]}"}; do
  if [ ${#running[@]} -ge "$jobs" ]; then
    wait "${running[0]}" 2>/dev/null
    running=("${running[@]:1}")
  fi
  run_one "$entry" &
  running+=($!)
done
wait
for entry in ${serial[@]+"${serial[@]}"}; do run_one "$entry"; done

passed=0
failed=()
for entry in ${parallel[@]+"${parallel[@]}"} ${serial[@]+"${serial[@]}"}; do
  test_name="${entry#*|}"
  if [ "$(cat "$TEST_TMP/$test_name.status" 2>/dev/null)" = ok ]; then
    printf '  \033[32m✓\033[0m %s\n' "$test_name"
    passed=$((passed + 1))
  else
    printf '  \033[31m✗\033[0m %s\n' "$test_name"
    sed 's/^/      /' "$TEST_TMP/$test_name.log" | tail -n 25
    failed+=("$test_name")
  fi
done

echo
if [ ${#failed[@]} -gt 0 ]; then
  echo "$passed passed, ${#failed[@]} failed: ${failed[*]}"
  exit 1
fi
echo "$passed passed"
