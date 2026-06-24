#!/usr/bin/env bash
set -euo pipefail

if ! command -v go >/dev/null 2>&1; then
	echo "error: go is not installed" >&2
	exit 1
fi

go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
