**English** · [Português](README.pt-BR.md)

# Terminals

tmux is the only dependency, so `work`, the panel and the shortcuts behave the
same in any terminal. What changes from one terminal to another are the extras:
the colors, the font and the terminal's own shortcuts.

The installer asks which terminal you use (kitty, Warp or another one), checks
that it is installed and sets up the extras it supports. **It does not install a
terminal:** if the one you chose is missing, it tells you where to download it,
and you run the installer again afterwards. To answer without the question, use
`--terminal kitty`, `--terminal warp` or `--terminal other`; the choice is saved
in `~/.config/workdeck/terminal`.

For kitty and Warp, a second question offers the workdeck **look**: the theme
and the JetBrains Mono font, downloaded from the official releases without sudo.
The default answer is no (Enter declines). `--visual` accepts without asking and
`--no-visual` declines; the answer is saved in `~/.config/workdeck/visual`.

## kitty

With kitty chosen and installed, the installer adds a block to your
`~/.config/kitty/kitty.conf` with the shortcuts:

- **Option as Alt** on a Mac, for the direct Alt shortcuts.
- **cmd** on a Mac: `cmd+h` opens the menu, `cmd+enter` splits the screen,
  `cmd+1…9` goes to a window, `cmd+d` / `cmd+shift+d` splits side by side /
  stacked, `cmd+shift+enter` zooms, `cmd+shift+w` closes the pane.
- **Shift+Enter** is sent in the extended format, so agents such as Claude Code
  get a new line instead of a submit. It only applies while tmux runs in the
  window, so a plain shell is not affected.

If you accept the look, the same block also gets:

- **Theme** from workdeck (`--theme`), the same as the tmux status bar.
- **Font** JetBrains Mono, with slightly larger line spacing.
- **Padding** of 8 points between the text and the window edge. With the
  theme, the kitty background matches the tmux background and the padding
  blends into it.

Without the look, kitty keeps its own theme and font. If an older workdeck
version already wrote the theme and font to your `kitty.conf`, the update keeps
them and saves that as your choice.

The installer finds kitty in `/Applications` or `~/Applications` (Mac), in
`~/.local/kitty.app` (Linux) or in the `PATH`. What you wrote outside the
`# >>> workdeck >>>` markers does not change, and the uninstaller removes only
the block. kitty itself stays installed.

## Warp

With [Warp](https://www.warp.dev/) chosen, the installer checks that it is
installed. `work` opens and tmux does the rest: the Alt shortcuts and the status
bar work as usual. The panel recognizes Warp through the `WARP_CLIENT_VERSION`
variable.

If you accept the look, the installer copies the theme to the Warp themes folder
and downloads the JetBrains Mono font:

| System | Where the theme goes |
|---|---|
| macOS | `~/.warp/themes/workdeck-<theme>.yaml` |
| Linux | `~/.local/share/warp-terminal/themes/workdeck-<theme>.yaml` |

Warp does not switch theme or font from a file, so the last step is yours:

- **Theme.** In **Settings › Appearance › Themes**, pick `workdeck <theme>`. You
  can also search for "Open theme picker" in the Command Palette. Warp may take a
  few minutes to notice the new folder; reopening the app fixes it.
- **Font.** In **Settings › Appearance › Text › Font type**, pick JetBrains Mono.
- **Option as Alt (Mac only).** The tmux Alt shortcuts (`Alt+1…9`, `Alt+↑/↓`)
  only work when Option is treated as Alt. In **Settings › Features**, turn on
  **Left Option key is Meta**. The installer does not turn it on for you, because
  Warp keeps this option in its own `settings.toml` and rewrites it.

What does **not** come to Warp: the `cmd` shortcuts. Warp's `keybindings.yaml`
only binds keys to Warp's own actions and has no action to send text, which is
what turns `cmd+1…9` and friends into the tmux prefix.

`work uninstall` removes the copied theme, unless you edited it.

If you attach from another terminal to a tmux session started in Warp, the
`WARP_CLIENT_VERSION` variable stays in the tmux environment and the panel shows
the Warp notice.

## Any other terminal

iTerm2, Ghostty, WezTerm, the terminal that ships with your system or an SSH
connection: `work` opens the same way, because the shortcuts belong to tmux. On a
Mac, set Option as Meta in the terminal settings to use the Alt shortcuts. The
theme and the font, if you want them, are set in the terminal itself.
