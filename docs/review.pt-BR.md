[English](review.md) · **Português**

# Self code review

Um review antes do commit: a sua IA lê a mudança e o código em volta e revisa
como a pessoa sênior que vai ser chamada se aquilo quebrar.

```bash
work review            # o que ainda não foi commitado
work review staged     # só o que está no stage (git add)
work review branch     # tudo o que a branch mudou em relação à principal
```

## O que ela devolve

Uma lista curta, uma bolinha por achado, sem explicação longa:

```
Usei: roteiro padrão

🔴 src/api/pedidos.ts:42 — o token vai inteiro para o log
   → logar só o id do usuário
🟠 src/lista.tsx:18 — uma consulta por item dentro do map
   → buscar todos de uma vez antes do map
🟢 os testes cobrem o caso novo

🔴 corrija os vermelhos antes do commit
```

| | Quer dizer | O que fazer |
|---|---|---|
| 🔴 | Bug: quebra, perde dado, abre falha de segurança ou não faz o que a mudança promete | Corrigir antes do commit |
| 🟠 | Atenção: funciona, mas é arriscado, lento, sem teste ou sobra | Vale corrigir; pode ficar para depois |
| 🟢 | Ok: o que foi conferido e está certo | Nada |

A última linha é o veredito: 🟢 pode commitar, 🟠 pode commitar e deixar os
laranjas para depois, ou 🔴 corrigir os vermelhos antes. Para entender um
achado em detalhe, pergunte na própria conversa do review, depois de corrigir.

Ela procura bugs e casos de borda, falhas de segurança (segredos, entrada sem
validação, injeção), código arriscado sem teste, lentidão com dados reais,
código morto ou de depuração e arquivos fora do escopo. Não altera nada: só
revisa.

## Onde ele roda

O review abre num painel embaixo do chat da sua IA (ou do painel em que você
está), separado da conversa que escreveu o código. Rodar de novo manda o pedido
para o mesmo painel.

Com o `claude`, cada branch tem uma sessão de review só: o `work review` retoma
a mesma conversa (`claude --resume`) em vez de criar uma por vez, e o `/resume`
não enche de reviews. Na conversa retomada, o que foi resolvido aparece como
`🟢 corrigido`, e o que continua aberto fica na lista.

Com `claude`, `codex` e `gemini`, o pedido entra direto na conversa. Com outra
IA, ele vai para a área de transferência e para
`~/.cache/workdeck/review-request.md`, para colar.

Qual IA é usada: a que estiver aberta num painel da janela. Se não houver
nenhuma, a escolhida na instalação, guardada como `AGENT_CMD` em `~/.config/workdeck/settings.conf`.

## O seu fluxo de review

O pedido manda a IA usar o agente de review e os PRDs ou stories que as
instruções dela apontam (`CLAUDE.md`, `AGENTS.md`, skills) — como o review do
[BMAD](https://github.com/bmad-code-org/BMAD-METHOD) ou uma skill própria — e
dizer na primeira linha qual usou. Sem nada configurado, ela faz o review
padrão descrito acima.

## Personalizar

Para acrescentar algo a todo review, como a branch base ou a skill preferida,
escreva em:

- `~/.config/workdeck/review.pt-BR.md` — vale para todos os projetos;
- `.workdeck/review.pt-BR.md` dentro do projeto — vale só nele.

O texto vai no fim do pedido e tem prioridade sobre as instruções padrão.

A ideia vem do passo de revisão do
[ponytail](https://github.com/dietrichgebert/ponytail).
