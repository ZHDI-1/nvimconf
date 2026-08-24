return {
	{ "dstein64/vim-startuptime", cmd = "StartupTime" },
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		config = function()
			require("config.oil").config()
		end,
		lazy = false,
	},
	{
		"akinsho/toggleterm.nvim",
		keys = { "<F5>" },
		config = function()
			require("config.terminal").config()
		end,
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup()
		end,
	},
	{
		"kevinhwang91/promise-async",
		lazy = true,
	},
	{
		"kevinhwang91/nvim-ufo",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			require("config.ufo").config()
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		main = "ibl",
		opts = {
			indent = {
				char = "▏",
			},
			scope = {
				enabled = true,
				show_exact_scope = true,
			},
		},
	},
	{ "mbbill/undotree", cmd = { "UndotreeToggle", "UndotreeShow" } },
	{ "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep" } },
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("config.gitsigns").config()
		end,
	},
	{
		"nvim-flutter/flutter-tools.nvim",
		ft = "dart",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim",
		},
		config = function()
			require("flutter-tools").setup({})
		end,
	},
	{
		"ZHDI-1/codex-history.nvim",
		branch = "main",
		build = "cargo install --path . --force",
		cmd = {
			"CodexHistory",
			"CodexHistoryRefresh",
			"CodexHistoryBack",
			"CodexHistoryFull",
			"CodexHistoryAnswers",
			"CodexHistoryToggle",
			"CodexHistoryExport",
		},
		keys = {
			{ "<leader>ch", "<cmd>CodexHistory<cr>", desc = "Browse Codex history" },
		},
		config = function()
			require("codex_history").setup()
		end,
	},
}
