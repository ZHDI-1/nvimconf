return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-context", branch = "master" },
		},
		config = function()
			require("config.treesitter").config()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		lazy = false,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					include_surrounding_whitespace = false,
				},
				move = {
					set_jumps = true,
				},
			})
		end,
	},
}
