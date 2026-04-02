#!/usr/bin/env bash
set -euo pipefail

if ! command -v rustup >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
  if prefix="$(brew --prefix rustup 2>/dev/null)"; then
    export PATH="$prefix/bin:$PATH"
  fi
fi

if ! command -v rustup >/dev/null 2>&1; then
  echo "error: rustup is not installed" >&2
  exit 1
fi

if ! rustup show active-toolchain >/dev/null 2>&1; then
  rustup default stable
fi

rustup component add rust-analyzer rust-src rustfmt
