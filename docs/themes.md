**English** · [Português](themes.pt-BR.md)

# Themes

Each theme colors tmux and, if you accept the look at install time, kitty too.
The Warp version of each theme stays in `themes/` for manual use.

While the session is open, `work` also asks the terminal to use the theme
background, so the margin around tmux does not show the terminal's own color
(such as the purple of the Ubuntu terminal). The terminal gets its color back
when you detach or run `work kill`. This uses the standard OSC 11 and OSC 111
sequences; a terminal without them keeps its margin color and nothing else
changes.

| Theme | Background | Character |
|---|---|---|
| `catppuccin-mocha` | `#1e1e2e` | Pastel by design. The default. |
| `nord` | `#2e3440` | Cool and desaturated. Green and red are close in luminance, which makes diffs harder to read. |
| `min-dark` | `#1f1f1f` | Neutral, derived from VS Code's Min Dark, with text contrast lowered to about 9.6:1. |

## Switching

```bash
curl -fsSL https://workdeck.dev/install | bash -s -- --theme nord
```

The choice is saved as `THEME` in `~/.config/workdeck/settings.conf`, and `work update` keeps the
chosen theme.

## Creating a theme

Create three files in `themes/`:

- `<name>.conf` with the kitty colors (`background`, `foreground`,
  `color0`–`color15`);
- `<name>.tmux` with the tmux colors (status bar, active window, pane borders,
  whose background is the same as the `window-style` one);
- `<name>.warp.yaml` with the Warp colors (`accent`, `cursor`, `background`,
  `foreground` and `terminal_colors`). Its `name` is `workdeck <name>`, which is
  how the theme shows up in the Warp theme picker.

The installer places each one where it belongs. Since themes live in the code,
a theme of your own requires a fork (see [Customizing](customizing.md)).

Check the contrast before settling on a theme. On a dark background, text above
11:1 is tiring in long sessions, and nothing below 4.5:1 should carry
information. Red and green also need to differ in luminance, not only in hue,
or diffs become hard to read on non-retina screens.
