**English** · [Português](review.pt-BR.md)

# Self code review

A review before the commit: your AI reads the change and the code around it and
reviews it like the senior engineer who gets called when it breaks.

```bash
work review            # what is not committed yet
work review staged     # only what is staged (git add)
work review branch     # everything the branch changed compared to the main branch
```

## What it returns

A short list, one colored dot per finding, without long explanations. The
review is written in Portuguese, like the rest of the workdeck interface:

```
Usei: roteiro padrão

🔴 src/api/pedidos.ts:42 — o token vai inteiro para o log
   → logar só o id do usuário
🟠 src/lista.tsx:18 — uma consulta por item dentro do map
   → buscar todos de uma vez antes do map
🟢 os testes cobrem o caso novo

🔴 corrija os vermelhos antes do commit
```

| | Means | What to do |
|---|---|---|
| 🔴 | Bug: breaks something, loses data, opens a security hole or does not do what the change promises | Fix it before the commit |
| 🟠 | Attention: works, but is risky, slow, untested or unnecessary | Worth fixing; can wait |
| 🟢 | Fine: what was checked and is correct | Nothing |

The last line is the verdict: 🟢 ready to commit, 🟠 ready to commit with the
orange items left for later, or 🔴 fix the red items first. To understand a
finding in detail, ask in the review conversation itself, after fixing it.

It looks for bugs and edge cases, security issues (secrets, unvalidated input,
injection), risky untested code, slowness with real data, dead or debug code,
and files outside the scope of the change. It does not change anything: it only
reviews.

## Where it runs

The review opens in a pane below your AI chat (or below the pane you are in),
separate from the conversation that wrote the code. Running it again sends the
request to the same pane.

With `claude`, each branch has a single review session: `work review` resumes
the same conversation (`claude --resume`) instead of starting a new one each
time, so `/resume` does not fill up with reviews. In the resumed conversation,
what was resolved shows up as `🟢 corrigido` (fixed), and what is still open
stays on the list.

With `claude`, `codex` and `gemini`, the request goes straight into the
conversation. With another AI, it goes to the clipboard and to
`~/.cache/workdeck/review-request.md`, for you to paste.

Which AI is used: the one open in a pane of the window. If there is none, the
one chosen during installation, stored as `AGENT_CMD` in `~/.config/workdeck/settings.conf`.

## Your own review flow

The request tells the AI to use the review agent and the PRDs or stories its
instructions point to (`CLAUDE.md`, `AGENTS.md`, skills), such as the
[BMAD](https://github.com/bmad-code-org/BMAD-METHOD) review or a skill of your
own, and to say on the first line which one it used. With nothing configured, it
runs the default review described above.

## Customizing

To add something to every review, such as the base branch or a preferred skill,
write it in:

- `~/.config/workdeck/review.md`, for all projects;
- `.workdeck/review.md` inside the project, for that project only.

The text goes at the end of the request and takes precedence over the default
instructions.

The idea comes from the review step in
[ponytail](https://github.com/dietrichgebert/ponytail).
