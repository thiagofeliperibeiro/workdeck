#!/usr/bin/env bash
# workdeck — desinstalador.
#
#   ./uninstall.sh            remove os blocos e os scripts; mantém sua config
#   ./uninstall.sh --restore  além disso, devolve os arquivos ao estado de antes
#                             da instalação, usando as cópias guardadas
#   ./uninstall.sh --all      remove tudo, inclusive ~/.config/workdeck e a fonte,
#                             e pergunta se o kitty sai também (é o work uninstall)
#   ./uninstall.sh --dry-run  mostra o que faria
#
# Em qualquer modo ele só mexe no que instalou: arquivo alterado por você
# depois da instalação é deixado em paz, e avisado.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/common.sh"
. "$ROOT/lib/json.sh"
. "$ROOT/lib/usage.sh"
CONFIG_DIR="$WORKDECK_CONFIG"
MANIFEST="$CONFIG_DIR/.install-manifest"
RESTORE=0
ALL=0
DRY=0
DELETE_CODE=""
CLAUDE_CREATED=""
ITERM_TEMPLATE_SUM="$(cksum < "$ROOT/terminals/iterm2.json" 2>/dev/null || true)"

for arg in "$@"; do
  case "$arg" in
    --restore) RESTORE=1 ;;
    --all) ALL=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opção desconhecida: $arg"; exit 1 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
run() { [ "$DRY" = 1 ] && { say "[dry-run] $*"; return 0; }; "$@"; }

remove_block() {
  local file="$1" tmp
  [ -f "$file" ] || return 0
  has_block "$file" || return 0
  if [ "$DRY" = 1 ]; then say "[dry-run] tiraria o bloco de ${file#"$HOME"/}"; return 0; fi
  tmp="$(mktemp)"
  without_block "$file" > "$tmp"
  mv "$tmp" "$file"
  say "bloco removido de ${file#"$HOME"/}"
}

echo "workdeck → desinstalando"
echo

[ "$DRY" = 1 ] || migrate_legacy_config

if [ -f "$MANIFEST" ]; then
  while IFS="|" read -r kind target backup; do
    [ -z "${kind:-}" ] && continue
    case "$kind" in
      block)
        if [ "$RESTORE" = 1 ] && [ -n "${backup:-}" ] && [ -f "$backup" ]; then
          run cp "$backup" "$target"
          say "${target#"$HOME"/} restaurado como estava antes"
        else
          remove_block "$target"
          if [ "${backup:-}" = ":created" ] && [ -f "$target" ] && ! grep -q '[^[:space:]]' "$target"; then
            run rm -f "$target"
            say "${target#"$HOME"/} apagado: foi criado pela instalação"
          fi
        fi
        ;;
      claude-statusline)
        current="$(json_get "$target" statusLine 2>/dev/null || true)"
        command=""
        [ -z "$current" ] || command="$(json_string_field "$current" command 2>/dev/null || true)"
        case "$command" in
          */workdeck-statusline)
            if [ "$DRY" = 1 ]; then
              say "[dry-run] devolveria a statusLine de ${target#"$HOME"/}"
            elif [ -s "$CLAUDE_PREVIOUS_STATUSLINE" ]; then
              json_set "$target" statusLine "$(cat "$CLAUDE_PREVIOUS_STATUSLINE")" && say "statusLine anterior devolvida em ${target#"$HOME"/}"
            else
              json_delete "$target" statusLine && say "statusLine removida de ${target#"$HOME"/}"
            fi
            ;;
          "") ;;
          *) say "deixei a statusLine de ${target#"$HOME"/}: foi alterada depois da instalação" ;;
        esac
        run rm -f "$CLAUDE_PREVIOUS_STATUSLINE"
        ;;
      claude-tui)
        if [ "$(json_get "$target" tui 2>/dev/null || true)" = '"fullscreen"' ]; then
          if [ "$DRY" = 1 ]; then
            say "[dry-run] tiraria o tui de ${target#"$HOME"/}"
          else
            json_delete "$target" tui && say "tui removido de ${target#"$HOME"/}"
          fi
        fi
        ;;
      claude-settings) CLAUDE_CREATED="$target" ;;
      kitty) ;;
      warp-theme)
        source_file="$ROOT/themes/$(basename "$target" .yaml | sed 's/^workdeck-//').warp.yaml"
        if [ ! -f "$target" ]; then
          :
        elif [ -f "$source_file" ] && same_file "$source_file" "$target"; then
          run rm -f "$target"
          say "removido ${target#"$HOME"/}"
        else
          say "deixei ${target#"$HOME"/}: foi alterado depois da instalação"
        fi
        ;;
      iterm-profile)
        if [ ! -f "$target" ]; then
          :
        elif [ -n "$ITERM_TEMPLATE_SUM" ] && [ "$(cksum < "$target")" = "$ITERM_TEMPLATE_SUM" ]; then
          run rm -f "$target"
          say "removido ${target#"$HOME"/}"
        else
          say "deixei ${target#"$HOME"/}: foi alterado depois da instalação"
        fi
        ;;
      tclock)
        run rm -f "$target"
        say "removido ${target#"$HOME"/}"
        ;;
      tclock-cargo)
        if command -v cargo >/dev/null && [ "$DRY" = 0 ]; then
          cargo uninstall --root "$HOME/.local" clock-tui >/dev/null 2>&1 || rm -f "$target"
        else
          run rm -f "$target"
        fi
        say "removido ${target#"$HOME"/}"
        ;;
      zsh)
        run rm -rf "$target"
        [ "$DRY" = 1 ] || setting_unset ZSH
        ;;
      omz|zinit)
        run rm -rf "$target"
        [ "$DRY" = 1 ] || setting_unset ZSH
        say "removido ${target#"$HOME"/}"
        ;;
      font)
        if [ "$ALL" = 1 ]; then
          run rm -f "$target"/JetBrainsMono*.ttf
          say "fonte JetBrains Mono removida de ${target#"$HOME"/}"
        fi
        ;;
      code)
        if [ -d "$target" ] && [ "$target" != "$ROOT" ]; then
          run rm -rf "$target"
          say "removido ${target#"$HOME"/}"
        elif [ -d "$target" ]; then
          DELETE_CODE="$target"
        fi
        run rm -rf "$WORKDECK_CACHE"
        ;;
      script)
        name="$(basename "$target")"
        source_file="$ROOT/bin/$name"
        if [ ! -f "$target" ]; then
          :
        elif [ -f "$source_file" ] && same_file "$source_file" "$target"; then
          run rm -f "$target"
          say "removido ${target#"$HOME"/}"
        else
          say "deixei ${target#"$HOME"/}: foi alterado depois da instalação"
        fi
        ;;
    esac
  done < "$MANIFEST"
  if [ -n "$CLAUDE_CREATED" ] && [ "$DRY" = 0 ] && [ -f "$CLAUDE_CREATED" ] && [ "$(tr -d ' \t\r\n' < "$CLAUDE_CREATED")" = "{}" ]; then
    rm -f "$CLAUDE_CREATED"
    say "${CLAUDE_CREATED#"$HOME"/} apagado: foi criado pela instalação"
  fi
else
  say "sem manifesto de instalação; removendo o que der"
  for f in "$HOME/.tmux.conf" "$HOME/.config/kitty/kitty.conf" \
           "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    remove_block "$f"
  done
  for script in "$ROOT"/bin/*; do
    target="$WORKDECK_BIN/$(basename "$script")"
    if [ -f "$target" ] && same_file "$script" "$target"; then
      run rm -f "$target"; say "removido ${target#"$HOME"/}"
    elif [ -f "$target" ]; then
      say "deixei ${target#"$HOME"/}: foi alterado depois da instalação"
    fi
  done
  if [ "$ALL" = 1 ] && [ "$ROOT" = "$WORKDECK_CODE" ]; then
    DELETE_CODE="$ROOT"
    run rm -rf "$WORKDECK_CACHE"
  fi
fi

echo
if [ "$ALL" = 1 ]; then
  run rm -rf "$CONFIG_DIR"
  run rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/git-review"
  say "removido $CONFIG_DIR, com projetos, painéis e cópias"
else
  say "sua config em ${CONFIG_DIR#"$HOME"/} continua lá (projetos, painéis e as cópias dos originais)"
  say "para apagar também:  ./uninstall.sh --all"
fi

kitty_apps() {
  local d
  for d in /Applications/kitty.app "$HOME/Applications/kitty.app" "$HOME/.local/kitty.app"; do
    [ -d "$d" ] && printf '%s\n' "$d"
  done
  return 0
}

offer_kitty_removal() {
  local apps answer app
  apps="$(kitty_apps)"
  [ -n "$apps" ] || return 0
  if [ "$ALL" = 0 ] || [ "$DRY" = 1 ] || [ ! -t 0 ]; then
    say "$(msg uninstall_kitty_kept)"
    return 0
  fi
  echo
  printf '%s' "$(msg uninstall_ask_kitty)"
  read -r answer || answer=n
  case "$answer" in
    s|S|y|Y) ;;
    *) say "$(msg uninstall_kitty_kept)"; return 0 ;;
  esac
  while IFS= read -r app; do
    if rm -rf "$app" 2>/dev/null; then
      say "$(msg uninstall_kitty_removed "${app/#$HOME/~}")"
    else
      say "$(msg uninstall_kitty_failed "${app/#$HOME/~}")"
    fi
  done <<< "$apps"
  for app in "$WORKDECK_BIN/kitty" "$WORKDECK_BIN/kitten"; do
    [ -L "$app" ] && rm -f "$app"
  done
  return 0
}

offer_kitty_removal

echo
echo "Reabra o terminal, ou:  tmux source-file ~/.tmux.conf"

if [ -n "$DELETE_CODE" ]; then
  run rm -rf "$DELETE_CODE"
  say "removido ${DELETE_CODE#"$HOME"/}"
fi

echo
print_logo "" "" "workdeck" "$(msg uninstall_goodbye)" "" "" "" "" ""
