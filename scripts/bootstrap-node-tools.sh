#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

if ! command -v fnm >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
	if prefix="$(brew --prefix fnm 2>/dev/null)"; then
		export PATH="$prefix/bin:$PATH"
	fi
fi

if ! command -v fnm >/dev/null 2>&1; then
	if ! command -v curl >/dev/null 2>&1; then
		echo "error: curl is required to install fnm" >&2
		exit 1
	fi

	curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

if [[ -x "$HOME/.local/share/fnm/fnm" ]]; then
	ln -sf "$HOME/.local/share/fnm/fnm" "$HOME/.local/bin/fnm"
fi

if ! command -v fnm >/dev/null 2>&1; then
	echo "error: fnm is not installed" >&2
	exit 1
fi

eval "$(fnm env --shell bash)"

is_fnm_managed() {
	local bin_path="$1"

	case "$bin_path" in
	"$HOME"/.local/share/fnm/* | "$HOME"/.local/state/fnm_multishells/* | /run/user/"$(id -u)"/fnm_multishells/*)
		return 0
		;;
	esac

	return 1
}

node_bin="$(command -v node || true)"
npm_bin="$(command -v npm || true)"

if [[ -z "$node_bin" || -z "$npm_bin" ]] || ! is_fnm_managed "$node_bin" || ! is_fnm_managed "$npm_bin"; then
	fnm install --lts
	fnm default lts-latest
	fnm use lts-latest
	eval "$(fnm env --shell bash)"
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
	echo "error: node/npm are not active after fnm bootstrap" >&2
	exit 1
fi

npm install -g \
	@fsouza/prettierd \
	@vue/language-server \
	bash-language-server \
	prettier \
	typescript \
	typescript-language-server \
	vscode-langservers-extracted
