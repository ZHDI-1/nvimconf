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
  "curl"
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

install_release_tool() {
  local name="$1"
  local repo="$2"
  local version="$3"
  local asset="$4"
  local binary_rel="$5"
  local tar_flag="$6"
  local install_root="${HOME}/.local/opt/${name}-${version}"
  local current_link="${HOME}/.local/opt/${name}"
  local bin_link="${HOME}/.local/bin/${name}"
  local tmpdir archive

  if command -v "$name" >/dev/null 2>&1; then
    return 0
  fi

  mkdir -p "${HOME}/.local/bin" "${HOME}/.local/opt"
  tmpdir="$(mktemp -d)"
  archive="${tmpdir}/${asset}"

  curl -fsSL -o "$archive" "https://github.com/${repo}/releases/download/${version}/${asset}"
  rm -rf "$install_root"
  mkdir -p "$install_root"
  tar -C "$install_root" "-x${tar_flag}f" "$archive"
  ln -sfn "$install_root" "$current_link"
  ln -sfn "${current_link}/${binary_rel}" "$bin_link"
  rm -rf "$tmpdir"
}

case "$(uname -m)" in
  x86_64|amd64)
    lua_ls_asset="lua-language-server-3.18.0-linux-x64.tar.gz"
    zls_asset="zls-x86_64-linux.tar.xz"
    ;;
  aarch64|arm64)
    lua_ls_asset="lua-language-server-3.18.0-linux-arm64.tar.gz"
    zls_asset="zls-aarch64-linux.tar.xz"
    ;;
  *)
    lua_ls_asset=""
    zls_asset=""
    ;;
esac

if [[ -n "${lua_ls_asset:-}" ]]; then
  install_release_tool \
    "lua-language-server" \
    "LuaLS/lua-language-server" \
    "3.18.0" \
    "$lua_ls_asset" \
    "bin/lua-language-server" \
    "z"
fi

if [[ -n "${zls_asset:-}" ]]; then
  install_release_tool \
    "zls" \
    "zigtools/zls" \
    "0.15.1" \
    "$zls_asset" \
    "zls" \
    "J"
fi

if ((${#missing_required[@]} > 0)); then
  printf 'missing required Fedora packages: %s\n' "${missing_required[*]}" >&2
fi

if ((${#missing_optional[@]} > 0)); then
  printf 'missing optional Fedora packages: %s\n' "${missing_optional[*]}"
fi
