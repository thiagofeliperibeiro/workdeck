**English** · [Português](shortcuts.pt-BR.md)

# Shortcuts

## Day to day

| To | Keys |
|---|---|
| **Open the menu** (projects, review, split…) | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Previous / next project | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Go to window N | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>1</kbd>…<kbd>9</kbd> |
| Split the screen (side by side or stacked, whichever fits) | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> |
| Pick the direction: side by side / stacked | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>v</kbd> / <kbd>-</kbd> |
| Previous / next pane | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Zoom the pane, and again to restore | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>z</kbd> |
| Close the pane | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd> |
| Detach and leave the session running | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>d</kbd> |

<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> means: press
<kbd>Ctrl</kbd>+<kbd>b</kbd>, release, then the key. The mouse works too:
click a window in the bottom bar, or a pane, and drag a border to resize.

In the menu, each project uses its window number as the key (pressing
<kbd>2</kbd> goes straight to the second one). <kbd>q</kbd> or <kbd>Esc</kbd>
closes the menu.

Only workdeck keys work after <kbd>Ctrl</kbd>+<kbd>b</kbd>; any other key shows
"tecla sem uso no workdeck — Ctrl+b h abre o menu" (key not used by workdeck).

## Single-key shortcuts with Alt

- <kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> goes to the window.
- <kbd>Alt</kbd>+arrows switches panes.
- <kbd>Alt</kbd>+<kbd>Shift</kbd>+letter runs the actions: <kbd>D</kbd> splits
  side by side, <kbd>S</kbd> stacked, <kbd>Z</kbd> zooms, <kbd>X</kbd> closes,
  <kbd>T</kbd> opens a window, <kbd>R</kbd> renames the window, <kbd>E</kbd>
  detaches without closing.

They work in any terminal. On a Mac, set Option as Meta in the terminal
settings; with kitty chosen at install time, workdeck does this for you, and in
Warp the option is **Left Option key is Meta**. The actions use Shift because `Alt`+lowercase
letter belongs to readline (moving and deleting words on the command line).

## Terminal extras

Every shortcut above belongs to tmux and works in any terminal. With kitty
chosen at install time, you also get `cmd` shortcuts on a Mac (`cmd+1…9` goes
to a window, `cmd+d` splits side by side, `cmd+h` opens the menu). What each
terminal gets is in [terminals/README.md](../terminals/README.md).

## Telling which pane is active

With two panes side by side, tmux paints only half of the shared border in the
active color, so it is easy to lose track of where the focus is. For a thin line
in the theme accent over the active pane, add this to
`~/.config/workdeck/settings.conf` and press <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd>:

```
ACTIVE_PANE="line"
```

The line takes one row at the top of the window. `"none"`, the default, keeps
the borders of the theme.

## Creating or changing a shortcut

Add the `bind` to your `~/.tmux.conf`, **after** the workdeck block: anything
before it is turned off together with the default tmux bindings, and the block
is rewritten on every update.

```tmux
bind -n M-S-G new-window -c "#{pane_current_path}" lazygit
```

Then <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>r</kbd> reloads the configuration.
