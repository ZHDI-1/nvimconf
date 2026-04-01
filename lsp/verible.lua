local util = require("config.lsp.util")

return {
  filetypes = { "systemverilog", "verilog" },
  cmd = {
    util.mason_bin("verible-verilog-ls"),
    "--rules_config_search",
    "--rules=-line-length,-no-trailing-spaces,-no-tabs",
  },
}
