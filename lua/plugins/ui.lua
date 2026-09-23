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
	{
		"folke/snacks.nvim",
		keys = {
			{
				"<leader>z",
				function()
					Snacks.zen()
				end,
				desc = "Toggle reading mode",
			},
		},
		opts = {
			zen = {
				toggles = {
					diagnostics = false,
					dim = false,
					git_signs = false,
				},
				win = {
					width = 100,
					wo = {
						breakindent = true,
						cursorline = false,
						foldcolumn = "0",
						foldenable = false,
						linebreak = true,
						list = false,
						number = false,
						relativenumber = false,
						signcolumn = "no",
						wrap = true,
					},
				},
			},
		},
	},
}
