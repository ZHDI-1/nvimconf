return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
      { "nvim-treesitter/nvim-treesitter-context", branch = "master" },
    },
    config = function()
      require("config.treesitter").config()
    end,
  },
}
