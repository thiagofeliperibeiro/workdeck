<div align="center">

# workdeck

**A framework for working with AI coding agents in the terminal, built on tmux.**

One window per project, your agent beside the code and a panel with the state
of everything, in a session that survives closing the terminal.

**English** · [Português](README.pt-BR.md)

[How it works](#how-it-works) ·
[Installation](#installation) ·
[Getting started](#getting-started) ·
[Features](#features) ·
[Documentation](#documentation)

[![CI](https://github.com/thiagofeliperibeiro/workdeck/actions/workflows/ci.yml/badge.svg)](https://github.com/thiagofeliperibeiro/workdeck/actions/workflows/ci.yml)
![macOS](https://img.shields.io/badge/macOS-supported-555?logo=apple)
![Linux](https://img.shields.io/badge/Linux-supported-555?logo=linux&logoColor=white)
![MIT License](https://img.shields.io/badge/license-MIT-555)

</div>

---

> workdeck speaks English or Brazilian Portuguese: the installer asks which one
> on the first run. The integrations, the uninstaller and `get.sh` are still in
> Portuguese and follow in the next version. The documentation is available in
> English and Portuguese.

## Why workdeck

Working with an AI agent in the terminal usually turns into a pile of tabs: the
agent in one place, git in another, a server running somewhere, and every
project with its own mess. workdeck puts all of it in one place.

- **One window per project.** `work` opens all of them at once; <kbd>Shift</kbd>+<kbd>←</kbd> <kbd>→</kbd> switches between them.
- **Your agent next to the code.** Works with any CLI agent: Claude Code, Codex, Copilot CLI, Aider, Gemini. None is bundled.
- **A panel with what matters.** The branch and changes of each project, plus anything else you want to see.
- **Know when an agent finishes.** While you work in one window, a ✦ in the status bar marks the window whose agent finished or is waiting for you, with an optional system notification.
- **See your plan limits.** The status bar shows how much of the 5-hour and weekly limits of Claude Code or Codex you have used.
- **Nothing gets lost.** Closed the terminal or lost the connection? Run `work` and everything is where you left it, agent included.
- **Any terminal, best in kitty.** workdeck runs on tmux, its only dependency, so `work` works the same in Warp, iTerm2 or the terminal your system ships with. In kitty, it also adds one-letter shortcuts.
- **Set up with one command, undone with another.** Installs tmux if it is missing, offers the kitty shortcuts and look; `work uninstall` reverts all of it.

## How it works

Each project is a window. Inside it, the agent sits next to your shell:

```
┌─ your terminal ──────────────────────────────────────────────┐
│                               │                              │
│  your AI agent                │  your shell                  │
│  (claude, codex…)             │  git, tests, server          │
│                               │                              │
├──────────────────────────────────────────────────────────────┤
│ 1 panel  2 api  3 web  4 mobile                 Shift+← →    │
└──────────────────────────────────────────────────────────────┘
```

The bottom bar lists the projects. Window 1 is the panel, with the branch and
changes of all of them.

The workflow:

```
work add ~/api  →  project window  →  agent beside it  →  commit
   once              always open        writes the code     you
```

## Installation

```bash
curl -fsSL https://workdeck.dev/install | bash
```

Runs on macOS and Linux (including WSL). The installer detects the system,
installs tmux if it is missing, offers the workdeck shortcuts and look in
[kitty](https://sw.kovidgoyal.net/kitty/) (and to download kitty, if you want)
and configures everything. Nothing is overwritten: what it
writes to your files stays between `# >>> workdeck >>>` markers.

<details>
<summary>Read the script before running it, or pass options</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh -o get.sh
less get.sh && bash get.sh
```

Options go at the end: `curl -fsSL … | bash -s -- --theme nord`. The full list
is in [docs/installation.md](docs/installation.md).

</details>

## Getting started

**1. Open a new terminal window** (or close and reopen the terminal, if the
installer ran inside it) to load the `work` command and the new shell.

**2. Start workdeck:**

```bash
work
```

The first time, it opens only the panel, showing what is left to set up.

**3. Add your projects:**

```bash
work add ~/code/api        # Tab completes the path
work add                   # without a path, uses the current folder
```

Each project becomes a window. Start your agent in one of them (`claude`,
`codex`…) and work as usual.

> **Lost?** <kbd>Ctrl</kbd>+<kbd>b</kbd> then <kbd>h</kbd> opens the menu with
> the projects, actions and shortcuts. <kbd>q</kbd> or <kbd>Esc</kbd> closes it.

## Features

### Commands

| Command | What it does |
|---|---|
| `work` | Opens the session, or returns to it |
| `work add [path]` | Adds a project as a window |
| `work update` | Shows what changed in the new version and updates |
| `work kill` | Closes the whole session |
| `work uninstall` | Removes everything workdeck installed |

### Shortcuts

Use [kitty](https://sw.kovidgoyal.net/kitty/) for the best experience: workdeck
adds its own shortcuts there, one letter each: <kbd>⌘</kbd> on a Mac, <kbd>Ctrl</kbd>+<kbd>Shift</kbd> in kitty on
Linux.

| To | macOS | Linux |
|---|---|---|
| **Open the menu** | <kbd>⌘</kbd>+<kbd>H</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>H</kbd> |
| Add a project | <kbd>⌘</kbd>+<kbd>P</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> |
| Go to project 1…9 | <kbd>⌘</kbd>+<kbd>1</kbd>…<kbd>9</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>1</kbd>…<kbd>9</kbd> |
| Previous / next project | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Open the agent / a terminal | <kbd>⌘</kbd>+<kbd>A</kbd> / <kbd>T</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>A</kbd> / <kbd>T</kbd> |
| Zoom / close the pane | <kbd>⌘</kbd>+<kbd>Z</kbd> / <kbd>W</kbd> | <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Z</kbd> / <kbd>W</kbd> |

In Warp, iTerm2, the system terminal or any other, the tmux shortcuts apply:
<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> opens the menu (press
<kbd>Ctrl</kbd>+<kbd>b</kbd>, release, then <kbd>h</kbd>) and
<kbd>Shift</kbd>+arrows switch projects and panes. Every shortcut is in
[docs/shortcuts.md](docs/shortcuts.md).

### Customizable panel

Window 1 is the panel: an overview of your work at the top and a terminal at
the bottom. It ships with the state of your projects, and you add whatever you
want to keep an eye on: containers, open pull requests, the CI build, today's
tasks.

Each block in the panel is a program in `~/.config/workdeck/panels/`. The panel
runs them in alphabetical order, shows what each one prints and repeats every
60 seconds. To add one:

```bash
cat > ~/.config/workdeck/panels/30-docker <<'EOF'
#!/usr/bin/env bash
docker ps --format '{{.Names}}  {{.Status}}'
EOF
chmod +x ~/.config/workdeck/panels/30-docker
```

On the next cycle, your containers show up under the title "Docker". Any
language works as long as it prints text; `chmod -x` turns a panel off,
including the built-in ones.
[Step by step, rules and ideas →](docs/panels.md)

### Themes

Three themes, applied to tmux and, if you accept the look, to kitty: `catppuccin-mocha` (default),
`nord` and `min-dark`. To switch, run the installer with `--theme nord`; the
choice is kept across updates.
[Create your own theme →](docs/themes.md)

## Updating and uninstalling

```bash
work update          # shows what changed and asks before updating
work uninstall       # shows what will be removed and asks before deleting
```

workdeck checks for new versions on its own, at most once a day and without
ever waiting on the network. Only published versions count; what changes in
each one is in the [CHANGELOG](CHANGELOG.md), in English and Portuguese, and
`work update` shows it in the terminal in your language. Updating keeps your projects, panels and choices.

The uninstaller removes only what workdeck installed. A kitty or oh-my-zsh you
already had stays, and your files can be restored to exactly how they were
before the installation. [Details →](docs/installation.md#uninstalling)

## Documentation

| Guide | Contents |
|---|---|
| [Installation](docs/installation.md) | Installer options, the zsh setup, where each file lives, uninstalling |
| [Projects](docs/projects.md) | Adding, removing and reordering; `projects.conf` |
| [Shortcuts](docs/shortcuts.md) | Every shortcut, the terminal extras and how to create your own |
| [Panels](docs/panels.md) | The built-in panels and how to write your own |
| [Themes](docs/themes.md) | The themes and how to create one |
| [Agent and integrations](docs/integrations.md) | The AI agent, BMAD, Spec Kit and ai-memory |
| [Customizing](docs/customizing.md) | What you can change and where |
| [Contributing](CONTRIBUTING.md) | Code layout, tests and how to send changes |
| [Security](SECURITY.md) | What the installer does and how to report a vulnerability |

## Philosophy

workdeck is for working with **CLI AI agents** (Claude Code, Codex, Gemini CLI,
Aider…) in the terminal. It organizes everything around the agent and replaces
none of it. Every feature serves one flow:

- **Project:** one window per project, back as you left it after closing the
  terminal.
- **Agent:** the agent in each project, the ✦ and the alert when it finishes,
  the usage limits in the status bar, and the panel with the state of
  everything.
- **Review:** the agent's own review commands before the commit.

It is not an editor or IDE extension, not a terminal and not an AI agent.
tmux is the engine underneath, and kitty gives the best experience.

workdeck is a starting point. It provides the structure (session, windows,
panel) and leaves the rest to you: your projects, your panels, your
agent. Everything lives in plain text files, and everything it writes can be
undone.

Use it, copy it, fork it and change whatever you need.

## License

[MIT](LICENSE)
