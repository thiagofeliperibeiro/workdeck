[English](installation.md) · **Português**

# Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/workdeckdev/workdeck/main/get.sh | bash
```

O `get.sh` baixa a versão publicada mais nova para `~/.local/share/workdeck`
e roda o `install.sh` de lá. Não é preciso clonar o repositório.

## O que o instalador faz

1. Detecta o sistema e o gerenciador de pacotes — brew no macOS; apt, dnf,
   pacman, zypper ou apk no Linux — e instala o tmux, se faltar.
2. Pergunta qual terminal você usa: [kitty](https://sw.kovidgoyal.net/kitty/),
   [Warp](https://www.warp.dev/) ou outro. Confere se o terminal está instalado
   e configura os extras dele. **O workdeck não instala terminal:** se o
   escolhido faltar, avisa onde baixar, e você roda a instalação de novo depois.
   No kitty e no Warp, uma segunda pergunta oferece o tema e a fonte JetBrains
   Mono do workdeck. As respostas ficam em `~/.config/workdeck/terminal` e
   `~/.config/workdeck/visual`, e `--terminal kitty|warp|other` e `--visual` /
   `--no-visual` respondem sem perguntar. Detalhes em
   [terminals/README.pt-BR.md](../terminals/README.pt-BR.md).
3. Coloca o comando `work` em `~/.local/bin`.
4. Escreve os blocos de configuração no `.tmux.conf` e no `.zshrc` (ou
   `.bashrc`). O `kitty.conf` só recebe o bloco se você escolheu o kitty e ele
   está instalado. Se você aceitou o visual no Warp, a instalação copia o tema
   para a pasta de temas dele.
5. Oferece o zsh do workdeck, pergunta qual é o seu agente de IA e quais
   integrações você usa.

É idempotente: rodar de novo atualiza em vez de duplicar. Tudo o que ele
escreve nos seus arquivos fica entre marcadores `# >>> workdeck >>>`, e o
desinstalador remove exatamente esse trecho. Se já existir um script seu com o
mesmo nome em `~/.local/bin`, o instalador não o substitui e avisa.

## Opções

As opções vão no fim do comando: `curl -fsSL … | bash -s -- --theme nord`.

| Opção | O que faz |
|---|---|
| `--theme <nome>` | Escolhe um tema de `themes/` (padrão: `catppuccin-mocha`); a escolha fica salva |
| `--agent <comando>` | Define o seu agente de IA sem perguntar (`claude`, `codex`…) |
| `--with <nome>` | Liga integrações sem perguntar: `bmad`, `spec-kit`, `ai-memory` (vírgula separa) |
| `--list-integrations` | Mostra as integrações disponíveis e sai |
| `--zsh` | Instala o oh-my-zsh e o zinit sem perguntar |
| `--yes` | Não pergunta nada; usa os padrões |
| `--no-deps` | Não instala nada pelo gerenciador de pacotes |
| `--no-reload` | Não recarrega o tmux no fim (útil ao instalar num HOME de teste) |
| `--dry-run` | Mostra o que faria, sem escrever nada |

Para mudar uma opção depois, rode o mesmo comando de instalação com ela.

## O zsh do workdeck

A instalação oferece um zsh pronto, com "sim" como resposta padrão: o
[oh-my-zsh](https://ohmyz.sh) com o tema robbyrussell
(`➜  projeto git:(main) ✗`) e o [zinit](https://github.com/zdharma-continuum/zinit)
com três plugins — sugestões enquanto digita (zsh-autosuggestions), cores nos
comandos (fast-syntax-highlighting) e mais coisa para completar com Tab
(zsh-completions). Tudo é carregado pelo bloco do workdeck no `.zshrc`; o resto
do arquivo fica como está.

- Se o seu `.zshrc` já carrega oh-my-zsh, zinit, Starship ou Powerlevel10k, ele
  não pergunta e não mexe. Uma pasta do oh-my-zsh ou do zinit que o `.zshrc`
  não carrega (sobra de outra instalação) não conta: ele reaproveita a pasta.
- No Linux sem zsh, ele instala o zsh e pergunta antes de trocar o seu shell
  padrão (pede a senha).
- Para outro tema do oh-my-zsh, ponha `export WORKDECK_ZSH_THEME=agnoster` (ou
  qualquer outro) no `~/.zshrc`, antes do bloco do workdeck.
- Para não usar, responda "n" na instalação.

## Onde fica cada coisa

```
~/.local/bin/work                   o único comando no PATH
~/.local/share/workdeck/            o código, na versão instalada
~/.config/workdeck/projects.conf    os seus projetos
~/.config/workdeck/panels/          os seus painéis
~/.config/workdeck/                 as suas escolhas: agente, tema, terminal, visual, zsh, integrações
~/.tmux.conf                        bloco entre os marcadores
~/.zshrc ou ~/.bashrc               bloco entre os marcadores
~/.config/kitty/kitty.conf          bloco entre os marcadores, só se você escolheu o kitty
~/.warp/themes/workdeck-*.yaml      o tema do Warp, só se você aceitou o visual (Mac)
~/.local/share/warp-terminal/themes/workdeck-*.yaml   o mesmo, no Linux
~/.oh-my-zsh, ~/.local/share/zinit  o zsh do workdeck, se você aceitou
```

## Atualizar

```bash
work update              # procura a versão nova, mostra o que mudou e pergunta
work update --desligar   # para de avisar; work update continua funcionando
work update --ligar      # volta a avisar
```

O `work` e o painel conferem sozinhos, no máximo uma vez por dia e em segundo
plano: nunca ficam esperando a internet, e sem rede não acontece nada. Quando
há versão nova, o `work` mostra o que mudou e pergunta antes de abrir a sessão;
se a resposta for não, ele não pergunta de novo sobre essa versão. Enquanto
houver uma versão para instalar, o painel mostra `● v1.0.0 → v1.1.0: work update`.

Só contam versões publicadas como tag (`v1.2.0`), não cada commit. A
atualização troca o código e reaplica a instalação; projetos, painéis, tema e
agente ficam como estão.

## Desinstalar

```bash
work uninstall              # mostra o que vai sair e pergunta antes
work uninstall --dry-run    # mostra o que faria, sem apagar
```

O `work uninstall` remove tudo o que o workdeck instalou: os blocos no
`.zshrc`, no `.tmux.conf` e no `kitty.conf` (se ele foi escrito), o tema do
Warp, o comando `work`, o código, o zsh do workdeck, a fonte e a config em
`~/.config/workdeck`. O que já existia antes da instalação fica: um kitty ou um
oh-my-zsh que você já tinha não sai. O kitty só sai se uma versão antiga do
workdeck o instalou.

Para remover menos, use o desinstalador direto:

```bash
bash ~/.local/share/workdeck/uninstall.sh             # tira os blocos e os scripts; a config fica
bash ~/.local/share/workdeck/uninstall.sh --restore   # devolve os arquivos ao estado de antes
```

Antes de tocar num arquivo pela primeira vez, o instalador guarda uma cópia em
`~/.config/workdeck/.backups/` e anota tudo o que fez num manifesto. O
`--restore` usa essas cópias: o `.tmux.conf` e o `.zshrc` voltam byte a byte ao
que eram. Script que você alterou depois da instalação fica, com aviso.
