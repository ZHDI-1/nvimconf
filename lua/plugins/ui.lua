return {
	{
		"ZHDI-1/lualine.nvim",
		branch = "lsp-progress-component",
		lazy = false,
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
