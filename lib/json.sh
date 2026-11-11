# Edits one top-level key of a JSON object file without jq, so workdeck keeps
# tmux as its only dependency. Everything else in the file is left byte for
# byte as it was. Only well-formed objects are handled; anything else makes
# the functions fail without touching the file.

# shellcheck disable=SC2016 # awk code, expanded by awk and not by the shell
JSON_TOP_AWK='
function fail() { bad = 1; exit 1 }
{ s = s (NR > 1 ? "\n" : "") $0 }
END {
  if (bad) exit 1
  n = length(s); depth = 0; instr = 0; esc = 0; state = ""; found = 0
  last = 0; lastkey_end = 0; keys = 0
  for (i = 1; i <= n; i++) {
    c = substr(s, i, 1)
    if (instr) {
      if (esc) esc = 0
      else if (c == "\\") esc = 1
      else if (c == "\"") {
        instr = 0
        if (depth == 1 && state == "key") { cur = substr(s, sstart + 1, i - sstart - 1); kstart = sstart; state = "colon"; continue }
      }
      if (depth >= 1) last = i
      continue
    }
    if (c ~ /[ \t\r\n]/) continue
    if (depth == 0) {
      if (c != "{" || opened) fail()
      opened = 1; depth = 1; state = "key"; ostart = i; continue
    }
    if (depth == 1 && state == "key") {
      if (c == "}" && keys == 0) { depth = 0; cend = i; continue }
      if (c != "\"") fail()
      instr = 1; sstart = i; continue
    }
    if (depth == 1 && state == "colon") { if (c != ":") fail(); state = "value"; vstart = 0; continue }
    if (depth == 1 && state == "value" && (c == "," || c == "}")) {
      if (!vstart) fail()
      keys++
      if (cur == key) { found = 1; fk = kstart; fvs = vstart; fve = last; fprev = prevcomma; fnext = (c == "," ? i : 0) }
      lastkey_end = last
      if (c == ",") { prevcomma = i; state = "key" } else { depth = 0; cend = i }
      continue
    }
    if (depth == 1 && state == "value" && !vstart) vstart = i
    if (c == "\"") { instr = 1; sstart = i; last = i; continue }
    if (c == "{" || c == "[") depth++
    else if (c == "}" || c == "]") depth--
    last = i
  }
  if (!opened || depth != 0 || instr) fail()
  if (mode == "get") { if (!found) exit 2; print substr(s, fvs, fve - fvs + 1); exit 0 }
  if (mode == "set") {
    if (found) out = substr(s, 1, fvs - 1) value substr(s, fve + 1)
    else if (keys == 0) out = substr(s, 1, ostart - 1) "{\n  \"" key "\": " value "\n}" substr(s, cend + 1)
    else out = substr(s, 1, lastkey_end) ",\n  \"" key "\": " value substr(s, lastkey_end + 1)
  } else if (mode == "delete") {
    if (!found) exit 2
    if (fprev) out = substr(s, 1, fprev - 1) substr(s, fve + 1)
    else if (fnext) {
      j = fnext + 1
      while (j <= n && substr(s, j, 1) ~ /[ \t\r\n]/) j++
      out = substr(s, 1, fk - 1) substr(s, j)
    } else out = substr(s, 1, ostart) "}" substr(s, cend + 1)
  }
  printf "%s\n", out
}'

# json_get FILE KEY: prints the raw value of KEY. Exit 2 when KEY is absent.
json_get() {
  [ -f "$1" ] || return 2
  JSON_KEY="$2" awk -v mode=get 'BEGIN { key = ENVIRON["JSON_KEY"] }'"$JSON_TOP_AWK" "$1"
}

# json_set FILE KEY RAW_VALUE: replaces KEY, or adds it after the last key.
json_set() { json_write "$1" set "$2" "$3"; }

# json_delete FILE KEY: removes KEY and its comma. Exit 2 when KEY is absent.
json_delete() { json_write "$1" delete "$2" ""; }

json_write() {
  local file="$1" tmp rc=0
  tmp="$(mktemp)" || return 1
  JSON_KEY="$3" JSON_VALUE="$4" awk -v mode="$2" 'BEGIN { key = ENVIRON["JSON_KEY"]; value = ENVIRON["JSON_VALUE"] }'"$JSON_TOP_AWK" "$file" > "$tmp" || rc=$?
  # Writes through the path, so a settings file that is a symlink stays one.
  [ "$rc" = 0 ] && { cat "$tmp" > "$file" || rc=1; }
  rm -f "$tmp"
  return "$rc"
}

# json_string_field RAW_OBJECT FIELD: prints a string field of a flat object,
# unescaped. Enough for a statusLine object, not a general JSON reader.
json_string_field() {
  printf '%s' "$1" | JSON_FIELD="$2" awk '
    { s = s (NR > 1 ? "\n" : "") $0 }
    END {
      field = "\"" ENVIRON["JSON_FIELD"] "\""
      n = length(s); i = 1
      while (i <= n) {
        c = substr(s, i, 1)
        if (c != "\"") { i++; continue }
        j = i + 1; v = ""
        while (j <= n) {
          d = substr(s, j, 1)
          if (d == "\\") {
            e = substr(s, j + 1, 1)
            if (e == "n") v = v "\n"; else if (e == "t") v = v "\t"; else if (e == "r") v = v "\r"; else v = v e
            j += 2; continue
          }
          if (d == "\"") break
          v = v d; j++
        }
        if (want) { print v; exit 0 }
        k = j + 1
        while (substr(s, k, 1) ~ /[ \t\r\n]/) k++
        if (substr(s, i, j - i + 1) == field && substr(s, k, 1) == ":") {
          k++
          while (substr(s, k, 1) ~ /[ \t\r\n]/) k++
          if (substr(s, k, 1) != "\"") exit 2
          i = k; want = 1; continue
        }
        i = j + 1
      }
      exit 2
    }'
}

json_quote() {
  printf '"%s"' "$(printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
}
