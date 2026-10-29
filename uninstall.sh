#!/usr/bin/env bash
# workdeck — desinstalador.
#
#   ./uninstall.sh            remove os blocos e os scripts; mantém sua config
#   ./uninstall.sh --restore  além disso, devolve os arquivos ao estado de antes
#                             da instalação, usando as cópias guardadas
#   ./uninstall.sh --all      remove tudo, inclusive ~/.config/workdeck, a fonte
#                             e o kitty que a instalação trouxe (é o work uninstall)
#   ./uninstall.sh --dry-run  mostra o que faria
#
# Em qualquer modo ele só mexe no que instalou: arquivo alterado por você
# depois da instalação é deixado em paz, e avisado.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/common.sh"
CONFIG_DIR="$WORKDECK_CONFIG"
MANIFEST="$CONFIG_DIR/.install-manifest"
RESTORE=0
ALL=0
DRY=0
DELETE_CODE=""

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
      kitty)
        if [ "$ALL" = 1 ]; then
          run rm -rf "$target"
          say "removido ${target#"$HOME"/}"
        else
          say "o kitty continua em ${target#"$HOME"/}; para remover também: rm -rf $target"
        fi
        ;;
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

echo
echo "Reabra o terminal, ou:  tmux source-file ~/.tmux.conf"

if [ -n "$DELETE_CODE" ]; then
  run rm -rf "$DELETE_CODE"
  say "removido ${DELETE_CODE#"$HOME"/}"
fi
