local project = require("core.project")

return {
  root_markers = {
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  },
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "standard",
      },
    },
  },
  before_init = function(_, config)
    config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
      python = {
        pythonPath = project.find_python_from_root(config.root_dir),
      },
    })
  end,
}
