**English** · [Português](themes.pt-BR.md)

# Themes

Each theme colors tmux and, if you accept the look at install time, kitty or
Warp too.

| Theme | Background | Character |
|---|---|---|
| `catppuccin-mocha` | `#1e1e2e` | Pastel by design. The default. |
| `nord` | `#2e3440` | Cool and desaturated. Green and red are close in luminance, which makes diffs harder to read. |
| `min-dark` | `#1f1f1f` | Neutral, derived from VS Code's Min Dark, with text contrast lowered to about 9.6:1. |

## Switching

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh | bash -s -- --theme nord
```

The choice is saved as `THEME` in `~/.config/workdeck/settings.conf`, and `work update` keeps the
chosen theme.

## Creating a theme

Create three files in `themes/`:

- `<name>.conf` with the kitty colors (`background`, `foreground`,
  `color0`–`color15`);
- `<name>.tmux` with the tmux colors (status bar, active window, pane borders);
- `<name>.warp.yaml` with the Warp colors (`accent`, `cursor`, `background`,
  `foreground` and `terminal_colors`). Its `name` is `workdeck <name>`, which is
  how the theme shows up in the Warp theme picker.

The installer places each one where it belongs. Since themes live in the code,
a theme of your own requires a fork (see [Customizing](customizing.md)).

Check the contrast before settling on a theme. On a dark background, text above
11:1 is tiring in long sessions, and nothing below 4.5:1 should carry
information. Red and green also need to differ in luminance, not only in hue,
or diffs become hard to read on non-retina screens.
