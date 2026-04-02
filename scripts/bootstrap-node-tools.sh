#!/usr/bin/env bash
set -euo pipefail

if ! command -v fnm >/dev/null 2>&1; then
  echo "error: fnm is not installed" >&2
  exit 1
fi

eval "$(fnm env --shell bash)"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  fnm install --lts
  fnm default lts-latest
  fnm use lts-latest
  eval "$(fnm env --shell bash)"
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "error: node/npm are not active after fnm bootstrap" >&2
  exit 1
fi

npm install -g \
  @fsouza/prettierd \
  @vue/language-server \
  bash-language-server \
  prettier \
  typescript \
  typescript-language-server \
  vscode-langservers-extracted
