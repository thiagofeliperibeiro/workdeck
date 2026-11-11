# workdeck

## What workdeck is

workdeck is a framework for working with AI coding agents in the terminal, built on tmux. In
spirit it is to tmux what oh-my-zsh is to zsh: it takes a powerful tool that is hard to set up and
ships it ready to use, with a way to extend it. Unlike a tmux configuration framework, most of it
is tooling rather than configuration: the `work` command, the context panel, the agent usage bar
and a reversible install.

tmux is the engine (sessions, windows, panes, keys); workdeck is the workflow on top of it: one
window per project, a CLI agent beside the code, a context panel, and an install that `work uninstall` fully reverts.

It is not a terminal, not a fork of tmux, not an editor integration and not an AI agent.

Use these rules to decide whether something belongs in workdeck:

1. It serves the flow project → agent → review → commit. Otherwise it stays out.
2. It is tmux configuration or a script on top of tmux. Anything that needs to change tmux itself
   stays out.
3. tmux is the only dependency. `work` behaves the same in any terminal; anything specific to one
   terminal (kitty, Warp, …) is an optional extra, and docs, panels and messages never treat
   another terminal as the exception.
4. It is reversible: the installer only adds marked blocks and recorded files, and
   `work uninstall` removes them.

## The site

The landing page lives in `site/`, a Next.js app with its own `package.json`, tests, CI workflow
(`.github/workflows/site.yml`) and `site/CLAUDE.md`. Follow `site/CLAUDE.md` for anything inside
`site/`; the rules below cover the rest of the repository. The `ci` workflow does not run for
changes that only touch `site/`, and the `site` workflow runs only for those.

## Language

| What | Language |
|---|---|
| Code: identifiers, functions, variables, file and folder names, comments, tests, CI | English |
| What the user sees in the terminal: CLI output, prompts, `--help`, panel titles, tmux messages | English and Brazilian Portuguese, in `lang/en.sh` and `lang/pt-BR.sh`, printed with `msg KEY args`; the user picks one at install (`LANGUAGE` in `settings.conf`) |
| `CHANGELOG.md`, shown by `work update` in the user's language | Both: each version has a `### Português` section and then an `### English` one. Portuguese comes first because versions before v1.6.0 print the start of the section as it is |
| Not translated yet: integration texts, `uninstall.sh`, `get.sh` | Brazilian Portuguese |
| READMEs and guides (`README.md`, `docs/`, `integrations/README.md`, `terminals/README.md`) | Both: `<name>.md` in English, `<name>.pt-BR.md` in Brazilian Portuguese |
| `CONTRIBUTING.md`, `SECURITY.md` | English |
| Commit messages, tag annotations | English |

- Each README and doc starts with a language switcher (`English | Português`) linking to its pair.
  A change to one language is mirrored in the other in the same commit, with the same structure.
- Files whose name the user sees on screen keep the Portuguese name, because the name is the text
  shown: panels in `config/panels/` (the file name becomes the panel title).
- File and config names the user does not read on screen are English. When a config file under
  `~/.config/workdeck/` is renamed, `install.sh` migrates the old name on the next `work update`,
  so nobody loses a choice already made.
- `instalar.sh` stays as a forwarder to `get.sh`, so the old one-line install URL keeps working.

## Writing style

- Professional and neutral, in the tone of a well-maintained open source CLI: short sentences,
  active voice, second person in docs ("you" / "você"), imperative in instructions.
- No first person, no jokes, no emoji in docs or CLI output.
- Name things the way the user sees them on screen: commands, keys, file paths.
- The Portuguese README and docs are written as natural Brazilian Portuguese, not as a literal
  translation of the English text.

## Versions

- Versions follow semantic versioning and are published as `vX.Y.Z` tags on `main`, each with
  its section in `CHANGELOG.md`, in both languages (`work update` shows the one in the user's language).
- Patch (`v1.0.1`): a fix users notice. Minor (`v1.1.0`): a new feature that keeps existing
  installs working as before. Major (`v2.0.0`): a change that breaks something users rely on,
  such as a removed command or a config that is no longer read.
- Not every commit is a version. Docs, tests, CI and internal refactors that change nothing for
  the user stay on `main` and go out with the next version that does.

## Commits

- Imperative subject line in English, up to 72 characters, no trailing period
  (`Add sprint panel example`, `Fix integration prompt parsing`).
- Optional body after a blank line explaining what changed and why, wrapped at 72 columns.
- One logical change per commit.
