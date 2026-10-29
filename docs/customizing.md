**English** · [Português](customizing.pt-BR.md)

# Customizing

Almost everything in workdeck is meant to be changed.

| To change | Where | Then |
|---|---|---|
| The projects and the window order | `~/.config/workdeck/projects.conf` | `work kill` and `work` |
| A keyboard shortcut | your `~/.tmux.conf`, after the workdeck block | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> |
| The `cmd` shortcuts and the kitty look | your `kitty.conf`, outside the workdeck block | reopen kitty |
| The colors | the installer with `--theme <name>` | — |
| The active pane highlight | `ACTIVE_PANE="line"` in `~/.config/workdeck/settings.conf` | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> |
| The AI agent, terminal and other saved choices | `~/.config/workdeck/settings.conf` | run the installer again |
| What the panel shows | `~/.config/workdeck/panels/` | nothing, it rereads on its own |
| What every review asks for | `~/.config/workdeck/review.md` or `.workdeck/review.md` | — |
| The oh-my-zsh theme | `export WORKDECK_ZSH_THEME=<theme>` in `.zshrc` | reopen the terminal |
| The session name | `export WORKDECK_SESSION=other` | — |
| Something not listed here | a fork, with your command in `bin/work` | `./install.sh` in the fork |

The installer only manages what is between the `# >>> workdeck >>>` markers;
the rest of your files remains yours. Anything you put outside those blocks
survives updates.

## The settings file

`~/.config/workdeck/settings.conf` holds the choices the installer remembers, one
`KEY="value"` per line. Lines starting with `#` are comments. Edit it by hand;
the installer fills in what is missing and only rewrites a key when you ask with a
flag such as `--theme` or `--terminal`.

| Key | Values | What it does |
|---|---|---|
| `TERMINAL` | `kitty`, `warp`, `other` | The terminal whose extras the installer sets up |
| `VISUAL` | `yes`, `no` | The workdeck theme and font in kitty or Warp |
| `THEME` | a theme name | The tmux colors |
| `AGENT_CMD` | a command | The AI that `work review` uses when none is open |
| `INTEGRATIONS` | `none` or a list | The optional integrations |
| `ZSH` | `yes`, `no` | The workdeck zsh |
| `NOTIFY` | `0` | `0` stops the new version notice (`work update --desligar`) |
| `ACTIVE_PANE` | `none` (default), `line` | A thin line over the active pane, in the theme accent |

Only exact `KEY="value"` lines count: `KEY=value`, `KEY = "value"` and
commented lines are ignored, and the first line of a key wins. Older versions
kept each choice in its own file; `work update` folds them into this one.

## Keeping your own version

Only `work` goes on the `PATH`. The other scripts in `bin/` are internal pieces,
called from the installation in `~/.local/share/workdeck`.

To go beyond configuration, fork the repository, change what you want and run
`./install.sh` from inside it. The installer copies your fork to
`~/.local/share/workdeck`, and `work update` then follows its versions.
