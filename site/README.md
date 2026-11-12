<div align="center">

# workdeck site

**The landing page for [workdeck](https://github.com/thiagofeliperibeiro/workdeck), a framework for working with AI coding agents in the terminal, built on tmux.**

A single page, in English and Portuguese, with animated terminals showing
workdeck in use: the workflow from `work add` to the review, the terminals,
the shortcuts and the customizable panel.

**English** · [Português](README.pt-BR.md)

[![site](https://github.com/thiagofeliperibeiro/workdeck/actions/workflows/site.yml/badge.svg)](https://github.com/thiagofeliperibeiro/workdeck/actions/workflows/site.yml)
![Next.js](https://img.shields.io/badge/Next.js-16-555?logo=nextdotjs)

</div>

---

> The site is available in English (`/en`, the default) and Brazilian
> Portuguese (`/pt-BR`). `/` redirects by the browser language, and the
> EN · PT switcher in the header remembers the choice in a cookie.

## Running

The site lives in `site/` inside the workdeck repository. Run every command
below from that folder.

```bash
cd site
npm install
npm run dev        # http://localhost:3000
```

| Script | What it does |
|---|---|
| `npm run dev` | Development server |
| `npm run build` | Production build |
| `npm run lint` | ESLint with the Next.js rules |
| `npm run typecheck` | Generates the route types (`next typegen`) and type-checks with TypeScript |
| `npm test` | Vitest in watch mode; `npx vitest run` runs once |

## Stack

- [Next.js](https://nextjs.org) with the App Router, one static page per language under `src/app/[lang]/`, following the Next.js internationalization guide
- `@formatjs/intl-localematcher` and `negotiator` to pick the language from the browser, in `src/proxy.ts`
- [shadcn/ui](https://ui.shadcn.com) and [Magic UI](https://magicui.design) components in `src/components/ui/`
- [Motion](https://motion.dev) for the terminal animations
- [Catppuccin Mocha](https://catppuccin.com) through `@catppuccin/tailwindcss`, the same palette as the default workdeck theme
- [Vitest](https://vitest.dev) and [Testing Library](https://testing-library.com) for tests

## Layout

```
src/app/[lang]/page.tsx           the page, section by section
src/app/[lang]/layout.tsx         the root layout, the page title and description per language
src/proxy.ts                      redirects / to /en or /pt-BR by cookie or browser language
src/lib/i18n.ts                   the languages, the default (en) and the cookie name
src/lib/dictionaries/             all the text, one file per language: en.ts and pt-BR.ts
src/lib/site.ts                   what does not change by language: version, repository and install command
src/lib/github.ts                 fetches the repository stars from the GitHub API, cached for hours
src/lib/stars.ts                  when to show the stars (10 or more) and how to format them (+23K)
src/components/terminal-parts.tsx the pieces of the animated terminals: window, panes, prompt, tmux bar, timeline
src/components/terminal-demo.tsx  the hero terminal: from `work` to the agent and its review
src/components/cycle-demo.tsx     the workflow, with clickable chapters
src/components/panel-demo.tsx     the panel gaining a new block
src/components/terminal-table.tsx the terminals table: what works everywhere and the extras of each
src/components/language-switcher.tsx the EN · PT switcher
src/components/ui/                components installed with the shadcn and Magic UI CLIs
tests/                            the tests
```

## Changing the content

Everything the page says lives in `src/lib/dictionaries/`, one file per
language. Change both files in the same commit, with the same structure: a
test fails when one language has an entry the other lacks. When workdeck
changes a command, a shortcut or a message, that is the place to update it,
and the source of truth is the README and the guides in `docs/` of the
[workdeck repository](https://github.com/thiagofeliperibeiro/workdeck).

The workdeck interface is in Brazilian Portuguese, so the animated terminals
keep what workdeck prints (the panel and the command messages) in
Portuguese in both languages; only the conversation with the agent and the
captions around it are translated. The English page says so below the
heading.

The animated terminals mimic the real workdeck: the command messages, the tmux
bar (`❯_ work`, the `1 painel` and `2 api` tabs, and the `✦` where the AI is
open) and the panel. If workdeck changes what it prints, update the animation
too.

### Version

`version`, in `src/lib/site.ts`, is the version shown in the top badge and in
the animated panel. Update it on every workdeck release.

## Tests

```bash
npx vitest run
```

The tests live in `tests/` and cover:

- **The content** (`site.test.ts`): both languages having the same structure and, in each one, the six workdeck commands, the four workflow steps, the install command pointing to the repository, the version in `vX.Y.Z` format, one value per terminal in each table row and the lists used as React keys having no duplicates.
- **The page** (`page.test.tsx`): the heading, each menu link pointing to an existing section, every command on screen, the version, GitHub and the install command, the stars on the GitHub link, the English page with the Portuguese interface notice, the language switcher marking the current language and an unknown language returning not found.
- **The stars** (`github.test.ts`): the GitHub API request, `null` when it fails and the `+23K` format.
- **The animation timeline** (`timeline.test.tsx`): advancing step by step, restarting at the end, jumping to a step and going straight to the end with reduced motion.
- **The animated workflow** (`cycle-demo.test.tsx`): starting outside workdeck, `work add` opening the window in the background, `Shift+→` going to it and the clickable chapters.

The `site` workflow runs lint, typecheck, tests and the build on Ubuntu when a
push to `main` or a pull request changes something in `site/`.

## Deploy

On Vercel: import the workdeck repository and set **Root Directory** to `site`.
The framework is detected automatically and there are no environment variables
to set.
