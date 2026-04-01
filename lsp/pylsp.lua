local project = require("core.project")

return {
  root_markers = {
    "pyproject.toml",
    "poetry.lock",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  },
  settings = {
    pylsp = {
      plugins = {
        black = { enabled = true, line_length = 80, preview = true },
        rope_autoimport = {
          enabled = true,
          completions = { enabled = false },
          code_actions = { enabled = true },
        },
        pycodestyle = {
          enabled = true,
          ignore = { "E501", "E231" },
          maxLineLength = 80,
        },
      },
    },
  },
  before_init = function(_, config)
    config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
      pylsp = {
        plugins = {
          jedi = {
            environment = project.find_python_from_root(config.root_dir),
          },
        },
      },
    })
  end,
}
