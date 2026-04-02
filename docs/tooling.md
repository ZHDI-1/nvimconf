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
  - `fnm` + `npm -g`
- Go tooling:
  - `go install`
- Rust tooling:
  - `rustup component add`

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

## Notes

- `ts_ls` uses `npm root -g` to locate `@vue/language-server` for Vue support.
- Python uses `ruff` and `basedpyright` now; `pylsp` is removed.
- `bootstrap-node-tools.sh` will install and activate the current Node LTS through `fnm` before installing npm-based language servers.
- `bootstrap-rust-tools.sh` will initialize `rustup` with `stable` if no default toolchain exists yet.
- `lemminx` and `verible-verilog-ls` are treated as optional in the bootstrap because package availability is inconsistent across package managers.
- `hdl_checker` is installed with `uv tool` because it is a Python package.
