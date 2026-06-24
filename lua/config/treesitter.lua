local M = {}

function M.config()
	local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter"

	local language_list = {
		"bash",
		"c",
		"cpp",
		"json",
		"lua",
		"markdown",
		"python",
		"query",
		"rust",
		"toml",
		"vim",
		"vimdoc",
		"zig",
	}

	local language_set = {}
	for _, lang in ipairs(language_list) do
		language_set[lang] = true
	end

	local disable_indent = {
		c = true,
		cpp = true,
	}

	local ts = require("nvim-treesitter")
	ts.setup({
		install_dir = parser_install_dir,
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
		callback = function(args)
			local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
			if not lang or not language_set[lang] or lang == "verilog" then
				return
			end

			local max_filesize = 100 * 1024
			local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
			if ok and stats and stats.size > max_filesize then
				return
			end

			local started = pcall(vim.treesitter.start, args.buf, lang)
			if started and not disable_indent[lang] then
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end,
	})

	vim.filetype.add({
		extension = {
			zsh = "sh",
			sh = "sh",
		},
		filename = {
			[".zshrc"] = "sh",
			[".zshenv"] = "sh",
			[".bashrc"] = "sh",
			[".bash_profile"] = "sh",
		},
	})

	require("treesitter-context").setup({
		enable = true,
		multiwindow = false,
		max_lines = 0,
		min_window_height = 0,
		line_numbers = true,
		multiline_threshold = 20,
		trim_scope = "outer",
		mode = "topline",
		separator = nil,
		zindex = 20,
		on_attach = nil,
	})
end

return M
