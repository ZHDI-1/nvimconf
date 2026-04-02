#!/usr/bin/env bash
set -euo pipefail

if ! command -v uv >/dev/null 2>&1; then
  echo "error: uv is not installed" >&2
  exit 1
fi

install_or_upgrade() {
  local tool="$1"
  uv tool install --upgrade --force "$tool"
}

install_or_upgrade basedpyright
install_or_upgrade ruff
install_or_upgrade hdl-checker
