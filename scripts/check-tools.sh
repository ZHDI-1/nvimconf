#!/usr/bin/env bash
set -euo pipefail

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

missing=0

check_cmd_impl() {
  local label="$1"
  local required="$2"
  shift
  shift
  local cmd

  for cmd in "$@"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf 'ok      %-24s %s\n' "$label" "$(command -v "$cmd")"
      return 0
    fi
  done

  printf 'missing %-24s %s\n' "$label" "$*"
  if [[ "$required" == "required" ]]; then
    missing=1
  fi
}

check_cmd() {
  check_cmd_impl "$1" required "${@:2}"
}

check_optional_cmd() {
  check_cmd_impl "$1" optional "${@:2}"
}

echo "[core]"
check_cmd neovim nvim
check_cmd git git
check_cmd ripgrep rg
check_cmd fd fd fdfind
check_cmd fzf fzf
check_cmd tmux tmux
check_cmd uv uv
check_cmd fnm fnm

echo
echo "[c-cpp]"
check_cmd clangd clangd
check_cmd clang-format clang-format

echo
echo "[python]"
check_cmd basedpyright basedpyright
check_cmd basedpyright-langserver basedpyright-langserver
check_cmd ruff ruff
check_cmd hdl_checker hdl_checker

echo
echo "[go]"
check_cmd go go
check_cmd gopls gopls
check_cmd goimports goimports

echo
echo "[rust]"
check_cmd rust-analyzer rust-analyzer
check_cmd rustfmt rustfmt

echo
echo "[zig]"
check_cmd zig zig
check_cmd zls zls

echo
echo "[lua-shell-toml]"
check_cmd lua-language-server lua-language-server
check_cmd shfmt shfmt
check_cmd stylua stylua
check_cmd taplo taplo

echo
echo "[web]"
check_cmd node node
check_cmd npm npm
check_cmd bash-language-server bash-language-server
check_cmd typescript-language-server typescript-language-server
check_cmd vue-language-server vue-language-server
check_cmd vscode-html-language-server vscode-html-language-server
check_cmd vscode-json-language-server vscode-json-language-server
check_cmd prettier prettier
check_cmd prettierd prettierd

echo
echo "[optional]"
check_optional_cmd lemminx lemminx
check_optional_cmd verible-verilog-ls verible-verilog-ls

exit "$missing"
