#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$(uname -s)" in
  Darwin)
    "$repo_root/scripts/bootstrap-brew.sh"
    ;;
  Linux)
    if command -v dnf >/dev/null 2>&1 || [[ -f /etc/fedora-release ]]; then
      "$repo_root/scripts/bootstrap-fedora.sh"
    else
      echo "skip: no Fedora/dnf bootstrap for this Linux host"
    fi
    ;;
  *)
    echo "skip: unsupported OS $(uname -s)"
    ;;
esac

if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if command -v brew >/dev/null 2>&1; then
  for formula in llvm rustup; do
    if prefix="$(brew --prefix "$formula" 2>/dev/null)"; then
      if [[ -d "$prefix/bin" ]]; then
        export PATH="$prefix/bin:$PATH"
      fi
    fi
  done
fi

if command -v go >/dev/null 2>&1; then
  export PATH="$(go env GOPATH)/bin:$PATH"
fi

if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --shell bash)"
fi

if command -v uv >/dev/null 2>&1; then
  "$repo_root/scripts/bootstrap-python-tools.sh"
else
  echo "skip: uv is not installed"
fi

if command -v go >/dev/null 2>&1; then
  "$repo_root/scripts/bootstrap-go-tools.sh"
else
  echo "skip: go is not installed"
fi

"$repo_root/scripts/bootstrap-rust-tools.sh"
"$repo_root/scripts/bootstrap-node-tools.sh"

"$repo_root/scripts/check-tools.sh"
