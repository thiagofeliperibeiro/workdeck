**English** · [Português](installation.pt-BR.md)

# Installation

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh | bash
```

`get.sh` downloads the latest published version to `~/.local/share/workdeck`
and runs `install.sh` from there. You do not need to clone the repository.

## What the installer does

1. Detects the system and the package manager (brew on macOS; apt, dnf,
   pacman, zypper or apk on Linux) and installs tmux if it is missing.
2. Asks which terminal you use: [kitty](https://sw.kovidgoyal.net/kitty/),
   [Warp](https://www.warp.dev/) or another one. It checks that the terminal is
   installed and sets up its extras. **workdeck does not install a terminal:**
   if the one you chose is missing, it tells you where to download it, and you
   run the installer again afterwards. For kitty and Warp, a second question
   offers the workdeck theme and the JetBrains Mono font. The answers are saved
   in `~/.config/workdeck/settings.conf` (`TERMINAL` and `VISUAL`), and
   `--terminal kitty|warp|other` and `--visual` / `--no-visual` answer without
   asking. Details in [terminals/README.md](../terminals/README.md).
3. Puts the `work` command in `~/.local/bin`.
4. Writes the configuration blocks to `.tmux.conf` and `.zshrc` (or
   `.bashrc`). `kitty.conf` only gets its block if you chose kitty and it is
   installed. If you accepted the look in Warp, the installer copies the theme
   to the Warp themes folder.
5. Offers the workdeck zsh setup and asks which AI agent and which
   integrations you use.

It is idempotent: running it again updates instead of duplicating. Everything
it writes to your files stays between `# >>> workdeck >>>` markers, and the
uninstaller removes exactly that block. If a script of yours with the same name
already exists in `~/.local/bin`, the installer leaves it alone and tells you.

## Options

Options go at the end of the command: `curl -fsSL … | bash -s -- --theme nord`.

| Option | What it does |
|---|---|
| `--theme <name>` | Picks a theme from `themes/` (default: `catppuccin-mocha`); the choice is saved |
| `--agent <command>` | Sets your AI agent without asking (`claude`, `codex`…) |
| `--with <name>` | Enables integrations without asking: `bmad`, `spec-kit`, `ai-memory` (comma separated) |
| `--list-integrations` | Lists the available integrations and exits |
| `--zsh` | Installs oh-my-zsh and zinit without asking |
| `--yes` | Asks nothing; uses the defaults |
| `--no-deps` | Installs nothing through the package manager |
| `--no-reload` | Does not reload tmux at the end (useful when installing into a test HOME) |
| `--dry-run` | Shows what it would do, without writing anything |

To change an option later, run the same install command with it.

## The workdeck zsh setup

The installer offers a ready-made zsh, with "yes" as the default answer:
[oh-my-zsh](https://ohmyz.sh) with the robbyrussell theme
(`➜  project git:(main) ✗`) and [zinit](https://github.com/zdharma-continuum/zinit)
with three plugins: suggestions as you type (zsh-autosuggestions), command
highlighting (fast-syntax-highlighting) and more Tab completions
(zsh-completions). All of it is loaded by the workdeck block in `.zshrc`; the
rest of the file stays as it is.

- If your `.zshrc` already loads oh-my-zsh, zinit, Starship or Powerlevel10k,
  the installer does not ask and does not touch it. An oh-my-zsh or zinit
  folder that `.zshrc` does not load (left over from another installation)
  does not count: the installer reuses the folder.
- On Linux without zsh, it installs zsh and asks before changing your default
  shell (it asks for your password).
- For another oh-my-zsh theme, add `export WORKDECK_ZSH_THEME=agnoster` (or any
  other) to `~/.zshrc`, before the workdeck block.
- To skip it, answer "n" during the installation.

## Where everything lives

```
~/.local/bin/work                   the only command on the PATH
~/.local/share/workdeck/            the code, at the installed version
~/.config/workdeck/projects.conf    your projects
~/.config/workdeck/panels/          your panels
~/.config/workdeck/settings.conf    your choices: agent, theme, terminal, visual, zsh, integrations, active pane
~/.tmux.conf                        block between the markers
~/.zshrc or ~/.bashrc               block between the markers
~/.config/kitty/kitty.conf          block between the markers, only if you chose kitty
~/.warp/themes/workdeck-*.yaml      the Warp theme, only if you accepted the look (Mac)
~/.local/share/warp-terminal/themes/workdeck-*.yaml   the same, on Linux
~/.oh-my-zsh, ~/.local/share/zinit  the workdeck zsh setup, if you accepted it
```

## Updating

```bash
work update              # looks for a new version, shows what changed and asks
work update --desligar   # stops the notices; work update keeps working
work update --ligar      # turns the notices back on
```

`work` and the panel check on their own, at most once a day and in the
background: they never wait on the network, and without a connection nothing
happens. When there is a new version, `work` shows what changed and asks before
opening the session; if you say no, it does not ask again about that version.
While a version is waiting to be installed, the panel shows
`● v1.0.0 → v1.1.0: work update`.

Only versions published as tags (`v1.2.0`) count, not every commit. Updating
replaces the code and reapplies the installation; projects, panels, theme and
agent stay as they are.

## Uninstalling

```bash
work uninstall              # shows what will be removed and asks first
work uninstall --dry-run    # shows what it would do, without deleting
```

`work uninstall` removes everything workdeck installed: the blocks in
`.zshrc`, `.tmux.conf` and `kitty.conf` (if it was written), the Warp theme,
the `work` command, the code, the workdeck zsh setup, the font and the config
in `~/.config/workdeck`. What existed before the installation stays: a kitty or
oh-my-zsh you already had is not removed. kitty is only removed if an older
workdeck version installed it.

To remove less, run the uninstaller directly:

```bash
bash ~/.local/share/workdeck/uninstall.sh             # removes the blocks and scripts; keeps the config
bash ~/.local/share/workdeck/uninstall.sh --restore   # restores your files to how they were before
```

Before touching a file for the first time, the installer saves a copy in
`~/.config/workdeck/.backups/` and records everything it does in a manifest.
`--restore` uses those copies: `.tmux.conf` and `.zshrc` go back byte for byte
to what they were. A script you changed after the installation is kept, with a
notice.
