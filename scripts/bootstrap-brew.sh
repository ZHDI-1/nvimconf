#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "error: Homebrew is not installed" >&2
  exit 1
fi

brew bundle --file "$repo_root/Brewfile" --no-upgrade
