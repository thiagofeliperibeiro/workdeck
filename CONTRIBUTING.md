# Contributing

Suggestions, bug reports and pull requests are welcome. For anything large,
open an issue first to discuss the idea.

## Setup

```bash
git clone https://github.com/workdeckdev/workdeck.git
cd workdeck
./install.sh
```

Running `install.sh` from inside the clone installs what is in it, including
commits that are not part of a release yet: it copies the clone to
`~/.local/share/workdeck`, which is where `work` runs from. After changing
something, commit it and run `./install.sh` again to use the change.

## Layout

```
install.sh            the installer, one function per step and main at the end
uninstall.sh          the uninstaller, driven by the installation manifest
get.sh                the one-line install (curl | bash)
instalar.sh           forwards to get.sh, so the old install URL keeps working
lib/common.sh         paths and helpers shared by every script
bin/work              the only command on the PATH
bin/work-panel        the panel
bin/workdeck-agent    starts the AI agent and the review in a pane
config/               tmux.conf, the shell block and the built-in panels
themes/               the kitty, tmux and Warp colors of each theme
terminals/            the kitty configuration and the terminals guide
integrations/         BMAD, Spec Kit, ai-memory and the template for new ones
docs/                 the guides, in English and Portuguese
tests/                the tests and the linter
```

## Language

| What | Language |
|---|---|
| Code: identifiers, file names, tests, CI, comments | English |
| What the user sees in the terminal: messages, prompts, `--help`, panel titles, `CHANGELOG.md` | Brazilian Portuguese |
| README and guides | Both: `<name>.md` in English and `<name>.pt-BR.md` in Portuguese, kept in sync |
| Commit messages | English |

Built-in panels keep Portuguese file names (`20-projetos`), because the file
name is the title shown on screen. When a file under `~/.config/workdeck/` is
renamed, `migrate_legacy_config` in `lib/common.sh` converts the old name on the
next install or update.

## Tests

```bash
./tests/run.sh          # all of them
./tests/run.sh theme    # only those with "theme" in the name
./tests/lint.sh         # shellcheck on every script
```

The tests need `tmux` and `git`, and the linter needs `shellcheck`. Nothing
touches your machine: each test runs in a throwaway HOME, with tmux on an
isolated server, and tests the current working tree, including uncommitted
changes.

Each `tests/*.test.sh` file contains `test_*` functions. The helpers
(`install_workdeck`, `assert`, `assert_contains`, `wait_for`,
`open_work_in_terminal`…) are in `tests/lib.sh`. Fixed a bug? Write the test
that would have caught it.

CI runs the linter and the tests on Ubuntu and macOS on every push and pull
request. On macOS the tests use the system `/bin/bash`, version 3.2, so avoid
bash 4+ features such as `mapfile`, `declare -A` and `${var,,}`.

## Testing by hand

Never install into a real account to test. Use a throwaway HOME and
`--no-reload`, otherwise the installer reloads the tmux of the session you have
open:

```bash
HOME="$(mktemp -d)" ./install.sh --yes --no-deps --no-reload
```

## Style

- Bash scripts with `set -euo pipefail` and small functions.
- Everything the installer writes stays between the `# >>> workdeck >>>`
  markers and can be undone by `uninstall.sh`.
- A change users will notice gets a line in `CHANGELOG.md`.

## Commits

- Imperative subject line in English, up to 72 characters, no trailing period:
  `Add sprint panel example`, `Fix integration prompt parsing`.
- Optional body after a blank line, explaining what changed and why.
- One logical change per commit.
