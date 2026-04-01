return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      require("core.theme").setup()
    end,
  },
  { "sainnhe/gruvbox-material", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "Mofiqul/vscode.nvim", lazy = true },
}
