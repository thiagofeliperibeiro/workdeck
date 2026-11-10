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

_work_projects() {
  command awk -F'|' '!/^[[:space:]]*#/ && NF >= 2 && $3 == "" { print $1 }' \
    "${XDG_CONFIG_HOME:-$HOME/.config}/workdeck/projects.conf" 2>/dev/null
}

if [ -n "${ZSH_VERSION:-}" ]; then
  _work() {
    if (( CURRENT == 2 )); then
      compadd add remove review update kill
    elif [[ ${words[2]} == add ]]; then
      _directories
    elif [[ ${words[2]} == remove || ${words[2]} == rm ]]; then
      compadd -- ${(f)"$(_work_projects)"}
    fi
  }
  (( $+functions[compdef] )) && compdef _work work
elif [ -n "${BASH_VERSION:-}" ]; then
  _work() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" = 1 ]; then
      COMPREPLY=($(compgen -W "add remove review update kill" -- "$cur"))
    elif [ "${COMP_WORDS[1]}" = add ]; then
      COMPREPLY=($(compgen -d -- "$cur"))
    elif [ "${COMP_WORDS[1]}" = remove ] || [ "${COMP_WORDS[1]}" = rm ]; then
      COMPREPLY=($(compgen -W "$(_work_projects)" -- "$cur"))
    fi
  }
  complete -o filenames -F _work work
fi
# <<< workdeck <<<
