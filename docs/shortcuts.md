**English** · [Português](shortcuts.pt-BR.md)

# Shortcuts

## kitty: the workdeck shortcuts

If you said yes to kitty at install time, workdeck sets up its own shortcuts in
it. The letter is the same everywhere: <kbd>⌘</kbd> on
a Mac, <kbd>Ctrl</kbd>+<kbd>Shift</kbd> in kitty on Linux.

| To | macOS | Linux |
|---|---|---|
| **Open the menu** (everything else is there) | <kbd>⌘</kbd>+<kbd>H</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>H</kbd> |
| Add a project | <kbd>⌘</kbd>+<kbd>P</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> |
| Go to project 1…9 | <kbd>⌘</kbd>+<kbd>1</kbd>…<kbd>9</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>1</kbd>…<kbd>9</kbd> |
| Previous / next project | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Open the agent in a new pane | <kbd>⌘</kbd>+<kbd>A</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>A</kbd> |
| Open a terminal in a new pane (2, 3, then 4 panes in a grid) | <kbd>⌘</kbd>+<kbd>T</kbd> or <kbd>⌘</kbd>+<kbd>Enter</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>T</kbd> or <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Enter</kbd> |
| Zoom the pane, and again to restore | <kbd>⌘</kbd>+<kbd>Z</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Z</kbd> |
| Close the pane | <kbd>⌘</kbd>+<kbd>W</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>W</kbd> |

The letters are meant to be remembered: **H**elp, **P**roject, **A**gent,
**T**erminal, **Z**oom, **R**eview, and <kbd>W</kbd> closes, as in any Mac
app. Splitting a specific way, renaming, detaching, updating and the agent alert
are in the menu.

## Any other terminal

Warp, iTerm2, the system terminal and the others keep the tmux shortcuts,
which work in any terminal:

| To | Keys |
|---|---|
| **Open the menu** | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Previous / next project | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Previous / next pane | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Go to window N | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>1</kbd>…<kbd>9</kbd> |
| Open a terminal in a grid | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>g</kbd> (or <kbd>Enter</kbd>) |
| Split side by side / stacked | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>v</kbd> / <kbd>-</kbd> |
| Zoom the pane | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>z</kbd> |
| Close the pane | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd> |
| Detach and leave the session running | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>d</kbd> |

<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> means: press
<kbd>Ctrl</kbd>+<kbd>b</kbd>, release, then the key. These also work in kitty
, for whoever already uses tmux. The mouse works too: click a window
in the bottom bar, or a pane, drag a border to resize, and drag a tab to reorder
your projects; the order is saved for the next `work`.

In the menu, each project uses its window number as the key. <kbd>q</kbd> or
<kbd>Esc</kbd> closes it.

### With Alt, in any terminal

<kbd>Alt</kbd>+<kbd>1</kbd>…<kbd>9</kbd> goes to the window and
<kbd>Alt</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> switches panes. On a Mac, they need
Option as Meta: kitty is set up by workdeck; for the others, see
[terminals/README.md](../terminals/README.md#any-other-terminal).

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
