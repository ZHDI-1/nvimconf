return {
  root_markers = {
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
    ".git",
  },
  on_attach = function(client)
    -- Prefer basedpyright hover and keep Ruff focused on lint/code actions.
    client.server_capabilities.hoverProvider = false
  end,
}
