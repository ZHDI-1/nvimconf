# Tooling Bootstrap

This config assumes external tools are already on `PATH`. Neovim configures them, but does not install them.

## Bootstrap Flow

On macOS:

```sh
./scripts/bootstrap-brew.sh
./scripts/bootstrap-python-tools.sh
./scripts/bootstrap-go-tools.sh
./scripts/bootstrap-rust-tools.sh
./scripts/bootstrap-node-tools.sh
./scripts/check-tools.sh
```

On Fedora:

```sh
./scripts/bootstrap-fedora.sh
./scripts/bootstrap-python-tools.sh
./scripts/bootstrap-go-tools.sh
./scripts/bootstrap-rust-tools.sh
./scripts/bootstrap-node-tools.sh
./scripts/check-tools.sh
```

Or run the wrapper:

```sh
./scripts/bootstrap.sh
```

## Tool Ownership

- System packages:
  - `brew` on macOS
  - `dnf` on Fedora
- Python tools:
  - `uv tool`
- Node and web tooling:
  - `fnm` owns the Node runtime on both macOS and Fedora
  - `npm -g` installs editor-specific language servers only after `fnm` has activated the current LTS
- Go tooling:
  - `go install`
- Rust tooling:
  - `rustup` owns the Rust toolchain and components
  - Cargo installs repo-specific Rust CLI tools that are not shipped as `rustup` components

## Shell Setup

Make sure your shell exposes the bins these installers use:

```sh
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
```

On macOS with Homebrew, also expose keg-only packages:

```sh
export PATH="$(brew --prefix llvm)/bin:$PATH"
export PATH="$(brew --prefix rustup)/bin:$PATH"
eval "$(fnm env --shell zsh)"
```

If you launch Neovim from GUI apps, a login shell, or a long-lived tmux server, put the PATH exports in your login shell file too:

- zsh: `~/.zprofile`
- bash: `~/.bash_profile` or `~/.profile`

Do not keep critical PATH setup only in `~/.zshrc` or `~/.bashrc`, because non-interactive launches may miss it.

## Notes

- `ts_ls` uses `npm root -g` to locate `@vue/language-server` for Vue support.
- Python uses `ruff` and `basedpyright` now; `pylsp` is removed.
- `bootstrap-node-tools.sh` is the only supported way to initialize Node for this repo; it will install `fnm` if needed, activate the current Node LTS, then install npm-based language servers into that `fnm`-managed runtime.
- `bootstrap-rust-tools.sh` is the only supported Rust bootstrap for this repo; it initializes `rustup` with `stable`, installs rustup components, and uses `cargo` only for editor-specific tools like `stylua` and `taplo`.
- `lemminx` and `verible-verilog-ls` are treated as optional in the bootstrap because package availability is inconsistent across package managers.
- `hdl_checker` is installed with `uv tool` because it is a Python package.
