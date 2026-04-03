#!/usr/bin/env bash
set -euo pipefail

if ! command -v fnm >/dev/null 2>&1; then
  echo "error: fnm is not installed" >&2
  exit 1
fi

eval "$(fnm env --shell bash)"

is_fnm_managed() {
  local bin_path="$1"

  case "$bin_path" in
    "$HOME"/.local/share/fnm/*|"$HOME"/.local/state/fnm_multishells/*|/run/user/"$(id -u)"/fnm_multishells/*)
      return 0
      ;;
  esac

  return 1
}

node_bin="$(command -v node || true)"
npm_bin="$(command -v npm || true)"

if [[ -z "$node_bin" || -z "$npm_bin" ]] || ! is_fnm_managed "$node_bin" || ! is_fnm_managed "$npm_bin"; then
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
