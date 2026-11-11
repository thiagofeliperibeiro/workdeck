# >>> workdeck >>>
# Works in bash and zsh.
export PATH="$HOME/.local/bin:$PATH"

if [ -n "${ZSH_VERSION:-}" ] && command grep -a -m1 '^ZSH=".*"$' "${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/settings.conf" 2>/dev/null | command grep -qx 'ZSH="yes"'; then
  if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME="${WORKDECK_ZSH_THEME:-robbyrussell}"
    plugins=(git)
    . "$ZSH/oh-my-zsh.sh"
  fi
  if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh" ]; then
    . "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh"
    zinit light zdharma-continuum/fast-syntax-highlighting
    zinit light zsh-users/zsh-autosuggestions
    zinit light zsh-users/zsh-completions
  fi
fi

# Inside tmux, a bare `claude` opens with the Claude Code diff panel, unless
# settings.conf has CLAUDE_DIFF_PANEL="no". An alias or function named claude
# that you already have wins.
if ! alias claude >/dev/null 2>&1 && ! typeset -f claude >/dev/null 2>&1; then
  function claude {
    if [ "$#" -eq 0 ] && [ -n "${TMUX:-}" ] && ! command grep -aqx 'CLAUDE_DIFF_PANEL="no"' "${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/settings.conf" 2>/dev/null; then
      command claude "/diff"
    else
      command claude "$@"
    fi
  }
fi

if [ -n "${ZSH_VERSION:-}" ]; then
  _work() {
    if (( CURRENT == 2 )); then
      compadd add update kill
    elif [[ ${words[2]} == add ]]; then
      _directories
    fi
  }
  (( $+functions[compdef] )) && compdef _work work
elif [ -n "${BASH_VERSION:-}" ]; then
  _work() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" = 1 ]; then
      COMPREPLY=($(compgen -W "add update kill" -- "$cur"))
    elif [ "${COMP_WORDS[1]}" = add ]; then
      COMPREPLY=($(compgen -d -- "$cur"))
    fi
  }
  complete -o filenames -F _work work
fi
# <<< workdeck <<<
