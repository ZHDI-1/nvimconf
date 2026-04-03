#!/usr/bin/env bash
set -euo pipefail

if ! command -v rustup >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
  if prefix="$(brew --prefix rustup 2>/dev/null)"; then
    export PATH="$prefix/bin:$PATH"
  fi
fi

rustup_init_bin=""

if command -v rustup-init >/dev/null 2>&1; then
  rustup_init_bin="$(command -v rustup-init)"
elif [[ -x /usr/bin/rustup-init ]]; then
  rustup_init_bin="/usr/bin/rustup-init"
elif [[ -x /usr/sbin/rustup-init ]]; then
  rustup_init_bin="/usr/sbin/rustup-init"
fi

if ! command -v rustup >/dev/null 2>&1 && [[ -n "$rustup_init_bin" ]]; then
  "$rustup_init_bin" -y --profile minimal --default-toolchain stable
  export PATH="$HOME/.cargo/bin:$PATH"
fi

if ! command -v rustup >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y rustfmt
  fi

  if command -v rustfmt >/dev/null 2>&1; then
    exit 0
  fi

  echo "error: rustup is not installed" >&2
  exit 1
fi

if ! rustup show active-toolchain >/dev/null 2>&1; then
  rustup default stable
fi

rustup component add rust-analyzer rust-src rustfmt
