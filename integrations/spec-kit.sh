#!/usr/bin/env bash

describe() {
  echo "Spec Kit"
  echo "Desenvolvimento guiado por especificação: spec, plano e tarefas antes do código."
  echo "Projeto de terceiros: https://github.com/github/spec-kit"
}

is_installed() {
  command -v specify >/dev/null
}

setup() {
  cat <<'EOF'
O Spec Kit usa o comando specify, distribuído pelo uv (Python).

  1. Instale o uv: https://docs.astral.sh/uv/
  2. Rode: uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
  3. Na pasta do projeto: specify init --here

Ele cria os comandos /speckit.* dentro do seu agente. O workdeck não depende
dele: tudo funciona com ou sem.
EOF
}
