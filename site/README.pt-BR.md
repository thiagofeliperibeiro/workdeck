<div align="center">

# site do workdeck

**O site de apresentação do [workdeck](https://github.com/thiagofeliperibeiro/workdeck), um framework para trabalhar com agentes de IA no terminal, construído sobre o tmux.**

Uma página só, em inglês e português, com terminais animados mostrando o
workdeck em uso: o ciclo do `work add` ao painel de diff, os terminais, os
atalhos e o painel personalizável.

[English](README.md) · **Português**

[![site](https://github.com/thiagofeliperibeiro/workdeck/actions/workflows/site.yml/badge.svg)](https://github.com/thiagofeliperibeiro/workdeck/actions/workflows/site.yml)
![Next.js](https://img.shields.io/badge/Next.js-16-555?logo=nextdotjs)

</div>

---

> O site está em inglês (`/en`, o padrão) e em português (`/pt-BR`). O `/`
> redireciona pelo idioma do navegador, e o seletor EN · PT do cabeçalho guarda
> a escolha num cookie.

## Rodando

O site fica em `site/`, dentro do repositório do workdeck. Rode todos os
comandos abaixo a partir dessa pasta.

```bash
cd site
npm install
npm run dev        # http://localhost:3000
```

| Script | O que faz |
|---|---|
| `npm run dev` | Servidor de desenvolvimento |
| `npm run build` | Build de produção |
| `npm run lint` | ESLint com as regras do Next.js |
| `npm run typecheck` | Gera os tipos das rotas (`next typegen`) e checa os tipos do TypeScript |
| `npm test` | Testes com Vitest, em modo watch; `npx vitest run` roda uma vez |

## Stack

- [Next.js](https://nextjs.org) com App Router, uma página estática por idioma em `src/app/[lang]/`, seguindo o guia de internacionalização do Next.js
- `@formatjs/intl-localematcher` e `negotiator` para escolher o idioma pelo navegador, no `src/proxy.ts`
- [shadcn/ui](https://ui.shadcn.com) e componentes do [Magic UI](https://magicui.design) em `src/components/ui/`
- [Motion](https://motion.dev) para as animações dos terminais
- [Catppuccin Mocha](https://catppuccin.com) pelo `@catppuccin/tailwindcss`, a mesma paleta do tema padrão do workdeck
- [Vitest](https://vitest.dev) e [Testing Library](https://testing-library.com) nos testes

## Estrutura

```
src/app/[lang]/page.tsx           a página, seção por seção
src/app/[lang]/layout.tsx         o layout raiz, o título e a descrição da página em cada idioma
src/proxy.ts                      leva o / para /en ou /pt-BR pelo cookie ou pelo idioma do navegador
src/lib/i18n.ts                   os idiomas, o padrão (en) e o nome do cookie
src/lib/dictionaries/             todo o texto, um arquivo por idioma: en.ts e pt-BR.ts
src/lib/site.ts                   o que não muda com o idioma: versão, repositório e comando de instalação
src/lib/github.ts                 busca as estrelas do repositório na API do GitHub, com cache de horas
src/lib/stars.ts                  quando mostrar as estrelas (a partir de 10) e como formatar (+23K)
src/components/terminal-parts.tsx as peças dos terminais animados: janela, painéis, prompt, barra do tmux, linha do tempo
src/components/terminal-demo.tsx  o terminal do topo: agente ao lado e painel de diff
src/components/cycle-demo.tsx     o ciclo de trabalho, com capítulos clicáveis
src/components/panel-demo.tsx     o painel ganhando um bloco novo
src/components/terminal-table.tsx a tabela de terminais: o que funciona em todos e os extras de cada um
src/components/language-switcher.tsx o seletor EN · PT
src/components/ui/                componentes instalados pelo CLI do shadcn e do Magic UI
tests/                            os testes
```

## Mudando o conteúdo

Tudo o que a página diz está em `src/lib/dictionaries/`, um arquivo por
idioma. Mude os dois no mesmo commit, com a mesma estrutura: um teste falha
quando um idioma tem uma entrada que o outro não tem. Quando o workdeck mudar
um comando, um atalho ou um texto, o lugar de ajustar é ali, e a fonte da
verdade é o README e os guias em `docs/` do
[repositório do workdeck](https://github.com/thiagofeliperibeiro/workdeck).

A interface do workdeck é em português, então os terminais animados mantêm em
português, nos dois idiomas, o que o workdeck imprime (o painel, as mensagens
dos comandos e o painel de diff). Só a conversa com o agente e as legendas em volta
são traduzidas. A página em inglês avisa isso abaixo do título.

Os terminais animados imitam o workdeck de verdade: as mensagens dos comandos,
a barra do tmux (`❯_ work`, as abas `1 painel`, `2 api` e o `✦` onde a IA está
aberta) e o painel. Se o workdeck mudar o que imprime, ajuste a animação junto.

### Versão

`version`, em `src/lib/site.ts`, é a versão mostrada no selo do topo e no painel
animado. Atualize a cada release do workdeck.

## Testes

```bash
npx vitest run
```

Os testes ficam em `tests/` e cobrem:

- **O conteúdo** (`site.test.ts`): os dois idiomas com a mesma estrutura e, em cada um, os seis comandos do workdeck, os quatro passos do ciclo, o comando de instalação apontando para o repositório, a versão no formato `vX.Y.Z`, um valor por terminal em cada linha da tabela e as listas que viram chave do React sem repetir.
- **A página** (`page.test.tsx`): o título, cada link do menu levando a uma seção que existe, todos os comandos na tela, a versão, o GitHub e o comando de instalação, as estrelas no link do GitHub, a página em inglês com o aviso da interface em português, o seletor marcando o idioma atual e um idioma desconhecido dando "não encontrado".
- **As estrelas** (`github.test.ts`): a busca na API do GitHub, o `null` quando ela falha e o formato `+23K`.
- **A linha do tempo das animações** (`timeline.test.tsx`): avançar passo a passo, recomeçar no fim, pular para um passo e ir direto para o fim com movimento reduzido.
- **O ciclo animado** (`cycle-demo.test.tsx`): começar fora do workdeck, o `work add` abrindo a janela em segundo plano, o `Shift+→` levando até ela e os capítulos clicáveis.

O workflow `site` roda lint, typecheck, testes e build no Ubuntu quando um push
na `main` ou um pull request muda algo em `site/`.

## Deploy

Na Vercel: importe o repositório do workdeck e ponha `site` em **Root
Directory**. O framework é detectado sozinho e não há variável de ambiente para
configurar.
