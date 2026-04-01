return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nanozuki/tabby.nvim",
    },
    config = function()
      require("config.statusline").config()
    end,
  },
  {
    "nanozuki/tabby.nvim",
    lazy = true,
  },
}
