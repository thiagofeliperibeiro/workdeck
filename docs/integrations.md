**English** · [Português](integrations.pt-BR.md)

# Agent and integrations

## The AI agent

workdeck neither ships nor starts any agent: you start yours as usual, in a
pane of the project window (`claude`, `codex`, `copilot`, `aider`, `gemini`…).
`work review` uses the AI open there. If there is none, it uses the one chosen
during installation, stored as `AGENT_CMD` in `~/.config/workdeck/settings.conf`.

To change it without being asked, run the installer with `--agent <command>`.

## Integrations

Nothing is installed by default. Each integration is a third-party tool that
shows up often when working with agents:

| Integration | What it is for |
|---|---|
| `bmad` | A framework that guides the AI through roles and stages (PRD, stories, review) |
| `spec-kit` | Specification-driven development |
| `ai-memory` | Memory across agent sessions |

On the first installation, the installer lists the integrations and asks which
ones you use. For each one you pick, it shows who maintains it, how to install
it and how to get the AI using it, even when it was already installed. The
answer is saved.

To enable one later:

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh | bash -s -- --with bmad,ai-memory
```

## Getting the AI to use them

When enabled, each integration explains how the AI starts using it. BMAD, for
example, is installed in the project with `npx bmad-method install` and makes
its commands (`bmad-help`, `bmad-build`) available in your AI.

What the integration cannot figure out on its own, state in the project's
`CLAUDE.md` (or `AGENTS.md`): where the PRDs and standards live, and which agent
to use for review. ai-memory complements those instructions with history, but
does not replace them.

workdeck is a workflow, not a package manager: these integrations are here
because they are common, not because the project maintains or has audited
them. To write your own, see [integrations/README.md](../integrations/README.md).
