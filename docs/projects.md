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

## Agent usage limits

The status bar has two lines, so a long list of projects never squeezes the
rest. The first holds the session and the projects. The second shows, on the
right, how much of your Claude or Codex plan you have used, with a bar for the
5-hour window and one for the weekly window, followed by the branch, the menu
key and the clock:

```
 ❯_ work   1 painel  2 api  3 web  4 mobile  5 admin  6 docs
          claude 5h ▰▰▱▱▱ 42% · 7d ▰▱▱▱▱ 12% · main · ctrl+b h menu · 14:05
```

It shows the agent running in the window you are looking at. In a window
without one, it shows the agent you used last. A bar turns red at 90%, and a
window whose reset time has passed is left out until the agent reports again.

- **Claude Code** passes these numbers only to its status line command. The
  installer sets `statusLine` in `~/.claude/settings.json` (or in
  `$CLAUDE_CONFIG_DIR`) to `~/.local/share/workdeck/bin/workdeck-statusline`.
  A status line you already had still shows in Claude, because workdeck runs it
  after saving the limits. `work uninstall` puts your previous `statusLine`
  back. The numbers come only with a Claude subscription (Pro or Max) and
  appear after the first answer of a session.
- **Codex** writes the limits to its session logs, in
  `~/.codex/sessions` (or in `$CODEX_HOME`). workdeck reads them and changes
  nothing in the Codex configuration. They come only with a ChatGPT plan.

Cursor and the other agents do not expose limits that workdeck can read, so
the status bar shows nothing for them.

## The project window

Each project window opens with a single pane, a plain shell ready for you to
start the agent (such as `claude`) in the projects you are going to work on.
Nothing starts on its own, so opening many projects does not start many agents
at once. <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> splits the window when
you need more panes, and <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>A</kbd> opens a pane
with your agent already running.

With Claude Code, the agent opens with the diff panel beside the conversation,
showing the files you changed: see [The diff panel in Claude Code](#the-diff-panel-in-claude-code).

### A shell beside the agent

To open each project window with the agent and a shell side by side, add this
to `~/.config/workdeck/settings.conf`, then run `work kill` and `work`:

```
PROJECT_LAYOUT="agent-shell"
```

```
┌──────────────┬──────────────┐
│              │              │
│  1 agent     │  2 shell     │
│              │              │
└──────────────┴──────────────┘
```

The shell is for git, tests and the server. The command in the project's
`.workdeck/project.conf` is typed in once the shell shows its prompt, without
running:

```
SERVER_COMMAND="npm run dev"
```

The file follows the same rules as `settings.conf`: one `KEY="value"` per
line, comments on lines of their own. A line in any other shape, such as one
with a comment after the value, is ignored. Control characters are removed
before typing, so a value never runs on its own. Without that file, the pane
opens as a plain shell. Since the server never starts on its own, ports do not
clash when many projects open at once.

## The diff panel in Claude Code

Claude Code has a diff panel, opened with `/diff`, that lists the files changed
in the project and shows what changed in each one. You can move through the
files without leaving the conversation. workdeck opens it for you:

- <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>A</kbd> starts Claude as `claude "/diff"`.
- Typing `claude` with no arguments in a workdeck pane does the same, through a
  `claude` function that the installer adds to the workdeck block of your
  `.zshrc` or `.bashrc`. Outside workdeck, and with any argument, such as
  `claude --resume`, `claude` runs as usual.

`/diff` runs inside Claude and sends nothing to the model. To start Claude
without the panel, add `CLAUDE_DIFF_PANEL="no"` to
`~/.config/workdeck/settings.conf`.

The panel needs the Claude Code fullscreen renderer. The installer sets
`"tui": "fullscreen"` in `~/.claude/settings.json` (or in `$CLAUDE_CONFIG_DIR`)
when you have not chosen a renderer yet, which is the same as running
`/tui fullscreen`. To go back to the default renderer, run `/tui default` in
Claude; workdeck keeps your choice. `work uninstall` removes the setting it
added.

## Another session

To use a different session name: `export WORKDECK_SESSION=other`.
