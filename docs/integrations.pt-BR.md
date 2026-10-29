[English](integrations.md) · **Português**

# Agente e integrações

## O agente de IA

O workdeck não traz nem abre nenhum agente: você abre o seu como sempre, num
painel da janela do projeto (`claude`, `codex`, `copilot`, `aider`, `gemini`…).
O `work review` usa a IA que estiver aberta ali. Se não houver nenhuma, usa a
escolhida na instalação, guardada como `AGENT_CMD` em `~/.config/workdeck/settings.conf`.

Para trocar sem perguntas: rode a instalação com `--agent <comando>`.

## Integrações

Nada é instalado por padrão. Cada integração é uma peça de terceiros que
aparece muito no trabalho com agentes:

| Integração | Para que serve |
|---|---|
| `bmad` | Framework que guia a IA por papéis e etapas (PRD, stories, review) |
| `spec-kit` | Desenvolvimento guiado por especificação |
| `ai-memory` | Memória entre sessões do agente |

Na primeira instalação, o instalador lista as integrações e pergunta quais você
usa. Para cada uma escolhida, mostra de quem é, como instalar e como deixar a
IA usando, mesmo quando ela já estava instalada. A resposta fica guardada.

Para ligar depois:

```bash
curl -fsSL https://raw.githubusercontent.com/thiagofeliperibeiro/workdeck/main/get.sh | bash -s -- --with bmad,ai-memory
```

## Deixar a IA usando

Cada integração diz, ao ser ligada, como a IA passa a usá-la. O BMAD, por
exemplo, é instalado no projeto com `npx bmad-method install` e já deixa os
comandos dele (`bmad-help`, `bmad-build`) prontos na sua IA.

O que a integração não sabe sozinha, diga no `CLAUDE.md` (ou no `AGENTS.md`) do
projeto: onde ficam os PRDs e os padrões, e qual agente usar no review. A
memória do ai-memory completa essas instruções com o histórico, mas não as
substitui.

O workdeck é um workflow, não um gerenciador de pacotes: estas integrações
estão aqui porque são comuns, não porque o projeto as mantém ou auditou. Para
escrever a sua, veja [integrations/README.pt-BR.md](../integrations/README.pt-BR.md).
