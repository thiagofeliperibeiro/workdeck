**English** · [Português](README.pt-BR.md)

# Terminals

tmux is the only dependency, so `work`, the panel and the tmux
shortcuts behave the same in any terminal. For the best experience, use
[kitty](https://sw.kovidgoyal.net/kitty/): it is the terminal where workdeck
adds its own shortcuts and, if you want, its theme and font.

## kitty, recommended

The installer asks whether you want the workdeck shortcuts in kitty. If kitty is
not installed yet, it offers to download it with kitty's official installer,
which needs no password. You can also say no and install it later: the
configuration is written anyway, so kitty opens ready. To answer without the
question, use `--terminal kitty` or `--terminal other`; the choice is saved in
`~/.config/workdeck/settings.conf` (`TERMINAL`).

The installer adds a block to your `~/.config/kitty/kitty.conf` with:

- **kitty opens straight into `work`.** The first window of kitty starts the
  workdeck session, so kitty works as the workdeck app; new windows (`⌘N`) open
  a plain shell, and leaving with <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>d</kbd>
  leaves a shell in the window. `KITTY_OPENS_WORK="no"` in `settings.conf`
  turns it off on the next install run, and a `startup_session` of your own in
  `kitty.conf` always wins.
- **A global key for workdeck.** kitty's quick access window is set to open
  `work`, so one key brings workdeck up over any app. On a Mac, pick the key
  once in System Settings › Keyboard › Keyboard Shortcuts › Services › General
  › "Quick access to kitty"; on Linux, bind `kitten quick-access-terminal` in
  the system keyboard settings. The config lives in a marked block in
  `~/.config/kitty/quick-access-terminal.conf`.
- **Agent alerts through kitty.** With `NOTIFY_AGENTS="yes"`, the alert that an
  agent finished comes from kitty, and clicking it brings kitty to the front.
- **The workdeck shortcuts**, <kbd>⌘</kbd> on a Mac and
  <kbd>Ctrl</kbd>+<kbd>Shift</kbd> on Linux: H menu, P add a project, 1…9 go to
  a project, A agent, T terminal, Z zoom, W close. The full table is
  in [docs/shortcuts.md](../docs/shortcuts.md).
- **Option as Alt** on a Mac, for the direct Alt shortcuts.
- **Shift+Enter** in the extended format, so agents such as Claude Code get a
  new line instead of a submit. It only applies while tmux runs in the window.

A second question offers the workdeck **look** in kitty: the theme (`--theme`,
the same as the tmux status bar), the JetBrains Mono font and 8 points of
padding. `--visual` accepts without asking and `--no-visual` declines; the
answer is saved as `VISUAL`.

`work uninstall` removes only the block: what you wrote outside the
`# >>> workdeck >>>` markers stays. It then asks whether to remove kitty too;
the default answer is no.

## Any other terminal

Warp, iTerm2, the macOS Terminal, Ghostty, WezTerm or an SSH connection: `work`
opens the same way, with the tmux shortcuts.

| To | Keys |
|---|---|
| Open the menu | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Previous / next project | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Previous / next pane | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Go to window N | <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> |

On a Mac, the Alt shortcuts need Option as Meta in the terminal settings:

- **iTerm2:** Settings › Profiles › Keys › Left Option key › Esc+.
- **Terminal:** Settings › Profiles › Keyboard › Use Option as Meta key.
- **Warp:** Settings › Features › Left Option key is Meta.

The theme and the font are set in the terminal itself. For Warp, the workdeck
themes are in `themes/<theme>.warp.yaml`: copy one to `~/.warp/themes/` and
pick it in Settings › Appearance › Themes.

Older versions copied the Warp theme and wrote an iTerm2 profile;
`work update` removes the iTerm2 profile, and `work uninstall` removes both,
unless you edited them.
