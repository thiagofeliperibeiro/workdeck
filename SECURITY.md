# Security

## Reporting a vulnerability

If you find a security issue, **do not open a public issue**. Use GitHub's
[private vulnerability reporting](https://github.com/workdeckdev/workdeck/security/advisories/new),
with steps to reproduce and the impact you see.

You will get a response as soon as possible, and the fix ships in a new
release, with the issue described in `CHANGELOG.md` once it is published.

## What the installer does

The recommended installation is `curl … | bash`. To read the script first:

```bash
curl -fsSL https://raw.githubusercontent.com/workdeckdev/workdeck/main/get.sh -o get.sh
less get.sh && bash get.sh
```

- **Where it writes:** only inside your HOME, and in your files (`.zshrc`,
  `.tmux.conf`, `kitty.conf`) only between the `# >>> workdeck >>>` markers.
- **Before writing:** it saves a copy of each file in
  `~/.config/workdeck/.backups/` and records everything in a manifest, which
  `uninstall.sh` uses to undo it.
- **When it asks for a password:** only to install tmux through the Linux
  package manager (`sudo`) and, if you accept, to change your default shell
  (`chsh`).
- **What it downloads:** workdeck itself from GitHub and, if you accept,
  oh-my-zsh and zinit from their repositories. It does not download a terminal;
  you install it. If you accept the terminal look, it also downloads the
  JetBrains Mono font from the official releases, without sudo.
- **What it does not do:** it sends no data anywhere, stores no tokens and runs
  nothing in the background except the new-version check, once a day, with
  `git fetch`.

## Panels and integrations

Panels are your own programs, run on every panel cycle. Do not put tokens in
them: read them from a file in `~/.config/workdeck/` (see
[docs/panels.md](docs/panels.md)). The integrations (BMAD, Spec Kit, ai-memory)
are third-party tools; workdeck only shows how to install them.
