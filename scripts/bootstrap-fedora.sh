#!/usr/bin/env bash
set -euo pipefail

if ! command -v dnf >/dev/null 2>&1; then
  echo "error: dnf is not installed" >&2
  exit 1
fi

pick_package() {
  local candidates=("$@")
  local candidate

  for candidate in "${candidates[@]}"; do
    if dnf -q info "$candidate" >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

installable=()
missing_required=()
missing_optional=()

required_specs=(
  "neovim"
  "git"
  "ripgrep"
  "fd-find fd"
  "fzf"
  "tmux"
  "clang-tools-extra"
  "golang go"
  "lua-language-server"
  "rustup"
  "shfmt"
  "stylua"
  "taplo taplo-cli"
  "tree-sitter-cli tree-sitter"
  "uv"
  "zig"
  "fnm"
)

optional_specs=(
  "zls"
  "lemminx"
  "verible verible-verilog-ls"
)

for spec in "${required_specs[@]}"; do
  # shellcheck disable=SC2206
  candidates=($spec)
  if pkg="$(pick_package "${candidates[@]}")"; then
    installable+=("$pkg")
  else
    missing_required+=("${candidates[0]}")
  fi
done

for spec in "${optional_specs[@]}"; do
  # shellcheck disable=SC2206
  candidates=($spec)
  if pkg="$(pick_package "${candidates[@]}")"; then
    installable+=("$pkg")
  else
    missing_optional+=("${candidates[0]}")
  fi
done

if ((${#installable[@]} > 0)); then
  sudo dnf install -y "${installable[@]}"
fi

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

if ((${#missing_required[@]} > 0)); then
  printf 'missing required Fedora packages: %s\n' "${missing_required[*]}" >&2
fi

if ((${#missing_optional[@]} > 0)); then
  printf 'missing optional Fedora packages: %s\n' "${missing_optional[*]}"
fi
