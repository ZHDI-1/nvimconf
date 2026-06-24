#!/usr/bin/env bash
set -euo pipefail

if ! command -v rustup >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
	if prefix="$(brew --prefix rustup 2>/dev/null)"; then
		export PATH="$prefix/bin:$PATH"
	fi
fi

if [[ -d "$HOME/.cargo/bin" ]]; then
	export PATH="$HOME/.cargo/bin:$PATH"
fi

if ! command -v rustup >/dev/null 2>&1; then
	rustup_init_bin=""

	if command -v rustup-init >/dev/null 2>&1; then
		rustup_init_bin="$(command -v rustup-init)"
	elif [[ -x /usr/bin/rustup-init ]]; then
		rustup_init_bin="/usr/bin/rustup-init"
	elif [[ -x /usr/sbin/rustup-init ]]; then
		rustup_init_bin="/usr/sbin/rustup-init"
	fi

	if [[ -n "$rustup_init_bin" ]]; then
		"$rustup_init_bin" -y --profile minimal --default-toolchain stable
	elif command -v curl >/dev/null 2>&1; then
		curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable
	fi

	export PATH="$HOME/.cargo/bin:$PATH"
fi

if ! command -v rustup >/dev/null 2>&1; then
	echo "error: rustup is not installed" >&2
	exit 1
fi

if ! rustup show active-toolchain >/dev/null 2>&1; then
	rustup default stable
fi

rustup component add rust-analyzer rust-src rustfmt

install_cargo_tool_if_missing() {
	local binary="$1"
	local crate="$2"

	if command -v "$binary" >/dev/null 2>&1; then
		return 0
	fi

	if ! command -v cargo >/dev/null 2>&1; then
		echo "error: cargo is not available after rustup bootstrap" >&2
		exit 1
	fi

	cargo install --locked "$crate"
}

install_cargo_tool_if_missing stylua stylua
install_cargo_tool_if_missing taplo taplo-cli
