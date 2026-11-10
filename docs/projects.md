**English** · [Português](projects.pt-BR.md)

# Projects

Each project is a window in the tmux session. `work` opens all of them at once,
and the session survives closing the terminal or losing the connection: run
`work` again and everything is where you left it, agent included. Restarting
the machine closes the session; `work` opens the project windows again, and you
start the agent again.

## Adding

```bash
work add ~/code/api        # Tab completes the path
work add                   # without a path, uses the current folder
```

The window name is the folder name. With the session open, the window appears
right away; if the folder is already in your work, nothing changes. In the menu
(<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd>), "Adicionar um projeto…" does the
same.

## Removing

Close the project window: `exit` in the last pane, or
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd>. It leaves the list, and the next
`work` no longer opens it. Closing only one of the split panes, or the agent,
removes nothing. To bring it back, run `work add` again.

A project whose folder no longer exists, such as a removed worktree, stays on
the list and shows "folder removed" in the panel, so a project on an
unmounted disk is not lost. To drop it, or any other project, use the name
shown in the panel:

```bash
work remove api           # Tab completes the name
work rm api               # the same, shorter
```

In the menu (<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd>), "Remove a project…"
lists the projects; click one, or press its number, to remove it. An open
window closes too.

## `projects.conf`

Projects are stored in `~/.config/workdeck/projects.conf`, one line per window:

```
name|path|optional command
```

```
panel|$HOME|work-panel
api|$HOME/projects/my-api
web|$HOME/projects/my-frontend
notes|~/notes
```

- **name** becomes the tmux window name.
- **path** is where the window opens; it accepts `~` and `$HOME`.
- **command** is optional: when present, the window runs it instead of a shell.

The `work-panel` line is the panel window. Its name follows your language
(`panel` or `painel`), and the installer renames it when you switch with
`--lang`.

The order of the file is the order of the windows, numbered from 1. A project
that does not exist on disk is skipped without an error, so you can keep lines
for repositories you have not cloned yet.

To reorder, edit the file, close the session with `work kill` and open it again
with `work`. Windows are created when the session opens; without closing it,
the session keeps the old list.

## Knowing when an agent finishes

While you work in one window, workdeck watches the agents open in the others.
When an agent finishes, or stops to ask you something, its window gets a ✦ in
the status bar. A window with several agents still shows a single star:

```
 ❯_ work   1 painel   2 api ✦   3 web   4 mobile
```

The star goes away when you open the window, or when every agent in it is
working again. Nothing is marked for the window you are looking at.

For Claude Code and Codex, workdeck knows an agent is working while its status
line near the message field shows "esc to interrupt"; the same words in the
conversation do not count. For other agents, it watches the screen change and
marks the window after 10 seconds without changes.

To also get a system notification ("claude finished in api"), choose
"Turn on the alert when an agent finishes" in the menu (<kbd>Ctrl</kbd>+<kbd>b</kbd>
<kbd>h</kbd>). The same item turns it off. It saves this line in
`~/.config/workdeck/settings.conf`, which you can also write by hand:

```
NOTIFY_AGENTS="yes"
```

It uses `osascript` on macOS and `notify-send` on Linux, when installed.

## Two panes per project

Each project window opens with the agent and a shell side by side. Every
`work` that opens the session opens all your projects this way.

```
┌──────────────┬──────────────┐
│              │              │
│  1 agent     │  2 shell     │
│              │              │
└──────────────┴──────────────┘
```

- **1, the agent:** a plain shell, ready for you to start the agent (such as
  `claude`) in the projects you are going to work on.
- **2, the shell:** for git, tests and the server. The command in the project's
  `.workdeck/project.conf` is typed in, also without running:

  ```
  SERVER_COMMAND="npm run dev"
  ```

  The file follows the same rules as `settings.conf`: one `KEY="value"` per
  line, comments on lines of their own. A line in any other shape, such as one
  with a comment after the value, is ignored. Control characters are removed
  before typing, so a value never runs on its own. Without that file, the pane
  opens as a plain shell.

The server command is typed once the shell shows its prompt. Nothing starts on its
own, so opening many projects does not start many agents or servers at once,
and ports do not clash. <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> splits the
window further when you need more panes.

To open each project window with a single pane, add this to
`~/.config/workdeck/settings.conf`, then run `work kill` and `work`:

```
PROJECT_LAYOUT="none"
```

## Another session

To use a different session name: `export WORKDECK_SESSION=other`.
