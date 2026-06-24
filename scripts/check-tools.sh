#!/usr/bin/env bash
set -euo pipefail

ORIGINAL_PATH="$PATH"

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

check_rc_contains() {
	local label="$1"
	local file="$2"
	local pattern="$3"

	if [[ ! -f "$file" ]]; then
		printf 'warn    %-24s missing file %s\n' "$label" "$file"
		return 0
	fi

	if grep -Eq "$pattern" "$file"; then
		printf 'ok      %-24s %s\n' "$label" "$file"
	else
		printf 'warn    %-24s add to %s\n' "$label" "$file"
	fi
}

check_original_path_cmd() {
	local label="$1"
	shift
	local cmd

	for cmd in "$@"; do
		if PATH="$ORIGINAL_PATH" command -v "$cmd" >/dev/null 2>&1; then
			printf 'ok      %-24s %s\n' "$label" "$(PATH="$ORIGINAL_PATH" command -v "$cmd")"
			return 0
		fi
	done

	printf 'warn    %-24s missing from current shell PATH\n' "$label"
}

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
echo "[shell]"
check_original_path_cmd current-rust rust-analyzer
check_original_path_cmd current-go gopls goimports
check_original_path_cmd current-python basedpyright ruff

current_shell="$(basename "${SHELL:-}")"
case "$current_shell" in
zsh)
	check_rc_contains zprofile-env-source "$HOME/.zprofile" '\.config/zsh/env\.zsh'
	check_rc_contains zshrc-interactive-source "$HOME/.zshrc" '\.config/zsh/interactive\.zsh'
	check_rc_contains zshrc-aliases-source "$HOME/.zshrc" '\.config/zsh/aliases\.zsh'
	check_rc_contains zsh-env-local-bin "$HOME/.config/zsh/env.zsh" 'local/bin'
	check_rc_contains zsh-env-go-bin "$HOME/.config/zsh/env.zsh" 'go/bin|GOPATH'
	check_rc_contains zsh-env-rust-bin "$HOME/.config/zsh/env.zsh" '\.cargo/bin|rustup/bin'
	check_rc_contains zsh-env-fnm "$HOME/.config/zsh/env.zsh" 'fnm env'
	check_rc_contains zsh-interactive-fnm "$HOME/.config/zsh/interactive.zsh" 'fnm env'
	;;
bash)
	check_rc_contains bashrc-local-bin "$HOME/.bashrc" 'local/bin'
	check_rc_contains bashrc-go-bin "$HOME/.bashrc" 'go/bin|GOPATH'
	check_rc_contains bashrc-rust-bin "$HOME/.bashrc" '\.cargo/bin|rustup/bin'
	check_rc_contains bashrc-fnm "$HOME/.bashrc" 'fnm env'
	check_rc_contains bash_profile-local-bin "$HOME/.bash_profile" 'local/bin|\\.bashrc|\\.profile'
	check_rc_contains bash_profile-go-bin "$HOME/.bash_profile" 'go/bin|GOPATH|\\.bashrc|\\.profile'
	check_rc_contains bash_profile-rust-bin "$HOME/.bash_profile" '\.cargo/bin|rustup/bin|\.bashrc|\.profile'
	;;
esac

echo
echo "[c-cpp]"
check_cmd clangd clangd
check_cmd clang-format clang-format

echo
echo "[python]"
check_cmd basedpyright basedpyright
check_cmd basedpyright-langserver basedpyright-langserver
check_cmd ruff ruff
check_optional_cmd hdl_checker hdl_checker

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
