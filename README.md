<div align="center">

# workdeck

**A framework for working with AI coding agents in the terminal, built on tmux.**

One window per project, your agent beside the code, a panel with the state of
everything, and a code review before every commit, in a session that survives
closing the terminal.

**English** · [Português](README.pt-BR.md)

[How it works](#how-it-works) ·
[Installation](#installation) ·
[Getting started](#getting-started) ·
[Features](#features) ·
[Documentation](#documentation)

[![CI](https://github.com/workdeckdev/workdeck/actions/workflows/ci.yml/badge.svg)](https://github.com/workdeckdev/workdeck/actions/workflows/ci.yml)
![macOS](https://img.shields.io/badge/macOS-supported-555?logo=apple)
![Linux](https://img.shields.io/badge/Linux-supported-555?logo=linux&logoColor=white)
![MIT License](https://img.shields.io/badge/license-MIT-555)

</div>

---

> The workdeck interface (CLI messages, prompts and panels) is in Brazilian
> Portuguese. The documentation is available in English and Portuguese.

## Why workdeck

Working with an AI agent in the terminal usually turns into a pile of tabs: the
agent in one place, git in another, a server running somewhere, and every
project with its own mess. workdeck puts all of it in one place.

- **One window per project.** `work` opens all of them at once; <kbd>Shift</kbd>+<kbd>←</kbd> <kbd>→</kbd> switches between them.
- **Your agent next to the code.** Works with any CLI agent: Claude Code, Codex, Copilot CLI, Aider, Gemini. None is bundled.
- **A panel with what matters.** The branch and changes of each project, plus anything else you want to see.
- **Review before you commit.** `work review` asks your AI to review the change, in a pane separate from the conversation that wrote the code.
- **Nothing gets lost.** Closed the terminal or lost the connection? Run `work` and everything is where you left it, agent included.
- **Any terminal.** workdeck runs on tmux, its only dependency. kitty, Warp, iTerm2 or the terminal your system ships with: `work` works the same in all of them.
- **Set up with one command, undone with another.** Installs tmux if it is missing, asks which terminal you use and offers its extras; `work uninstall` reverts all of it.

## How it works

Each project is a window. Inside it, the agent sits next to your shell, and the
review opens below the agent when you ask for it:

```
┌─ your terminal ──────────────────────────────────────────────┐
│                               │                              │
│  your AI agent                │  your shell                  │
│  (claude, codex…)             │  git, tests, server          │
│                               │                              │
├───────────────────────────────┤                              │
│  work review                  │                              │
│  the AI reviews the change    │                              │
│                               │                              │
├──────────────────────────────────────────────────────────────┤
│ 1 painel  2 api  3 web  4 mobile                 Shift+← →   │
└──────────────────────────────────────────────────────────────┘
```

The bottom bar lists the projects. Window 1 is the panel, with the branch and
changes of all of them.

The workflow:

```
work add ~/api  →  project window  →  agent beside it  →  work review  →  commit
   once              always open        writes the code     reviews first     you
```

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/workdeckdev/workdeck/main/get.sh | bash
```

Runs on macOS and Linux (including WSL). The installer detects the system,
installs tmux if it is missing, asks which terminal you use
([kitty](https://sw.kovidgoyal.net/kitty/), [Warp](https://www.warp.dev/) or
another one) and configures everything. You install the terminal yourself; the
workdeck theme and font in it are optional. Nothing is overwritten: what it
writes to your files stays between `# >>> workdeck >>>` markers.

<details>
<summary>Read the script before running it, or pass options</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/workdeckdev/workdeck/main/get.sh -o get.sh
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

**4. Before committing, ask for a review:**

```bash
work review
```

> **Lost?** <kbd>Ctrl</kbd>+<kbd>b</kbd> then <kbd>h</kbd> opens the menu with
> the projects, actions and shortcuts. <kbd>q</kbd> or <kbd>Esc</kbd> closes it.

## Features

### Commands

| Command | What it does |
|---|---|
| `work` | Opens the session, or returns to it |
| `work add [path]` | Adds a project as a window |
| `work review [staged\|branch]` | Your AI reviews the change before the commit |
| `work update` | Shows what changed in the new version and updates |
| `work kill` | Closes the whole session |
| `work uninstall` | Removes everything workdeck installed |

### Shortcuts

| To | Keys |
|---|---|
| **Open the menu** | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> |
| Previous / next project | <kbd>Shift</kbd>+<kbd>←</kbd> / <kbd>→</kbd> |
| Previous / next pane | <kbd>Shift</kbd>+<kbd>↑</kbd> / <kbd>↓</kbd> |
| Go to window N | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>1</kbd>…<kbd>9</kbd> (on a Mac: <kbd>cmd</kbd>+<kbd>1</kbd>…<kbd>9</kbd>) |
| Split the screen | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>Enter</kbd> |
| Zoom the pane | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>z</kbd> |
| Close the pane | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>x</kbd> |
| Detach and leave everything running | <kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>d</kbd> |

<kbd>Ctrl</kbd>+<kbd>b</kbd> <kbd>h</kbd> means: press
<kbd>Ctrl</kbd>+<kbd>b</kbd>, release, then press <kbd>h</kbd>. The mouse works
too. Every shortcut, including the single-key Alt ones, is in
[docs/shortcuts.md](docs/shortcuts.md).

### Self code review

`work review` sends the change to your AI for review before the commit, and
the answer comes back short, one colored dot per finding:

```
🔴 src/api/orders.ts:42 — the full token is written to the log
   → log only the user id
🟠 src/list.tsx:18 — one query per item inside the map
   → fetch everything once before the map

🔴 fix the red items before committing
```

🔴 is a bug, to fix before the commit; 🟠 needs attention and can wait; 🟢 is
fine. The AI only reviews; it does not change anything. The review itself is
written in Portuguese.

The review uses the agent and standards your project instructions point to
(`CLAUDE.md`, `AGENTS.md`, skills). With Claude Code, each branch keeps a
single review conversation that remembers what was already pointed out.
[How it works and how to customize it →](docs/review.md)

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

Three themes, applied to tmux and, if you accept the look, to kitty or Warp: `catppuccin-mocha` (default),
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
each one is in the [CHANGELOG](CHANGELOG.md) (in Portuguese, since `work update`
shows it in the terminal). Updating keeps your projects, panels and choices.

The uninstaller removes only what workdeck installed. A kitty or oh-my-zsh you
already had stays, and your files can be restored to exactly how they were
before the installation. [Details →](docs/installation.md#uninstalling)

## Documentation

| Guide | Contents |
|---|---|
| [Installation](docs/installation.md) | Installer options, the zsh setup, where each file lives, uninstalling |
| [Projects](docs/projects.md) | Adding, removing and reordering; `projects.conf` |
| [Shortcuts](docs/shortcuts.md) | Every shortcut, the terminal extras and how to create your own |
| [Review](docs/review.md) | How `work review` works and how to customize it |
| [Panels](docs/panels.md) | The built-in panels and how to write your own |
| [Themes](docs/themes.md) | The themes and how to create one |
| [Agent and integrations](docs/integrations.md) | The AI agent, BMAD, Spec Kit and ai-memory |
| [Customizing](docs/customizing.md) | What you can change and where |
| [Contributing](CONTRIBUTING.md) | Code layout, tests and how to send changes |
| [Security](SECURITY.md) | What the installer does and how to report a vulnerability |

## Philosophy

workdeck is a starting point. It provides the structure (session, windows,
panel, review) and leaves the rest to you: your projects, your panels, your
agent. Everything lives in plain text files, and everything it writes can be
undone.

Use it, copy it, fork it and change whatever you need.

## License

[MIT](LICENSE)
