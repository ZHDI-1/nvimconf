local M = {}

function M.config()
	local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter"

	local disable_indent = {
		c = true,
		cpp = true,
	}

	local ts = require("nvim-treesitter")
	ts.setup({
		install_dir = parser_install_dir,
	})

	local available_languages = {}
	for _, lang in ipairs(ts.get_available()) do
		available_languages[lang] = true
	end

	local pending_buffers = {}
	local install_tasks = {}

	local function set_indentexpr(bufnr, lang)
		if not disable_indent[lang] then
			vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end

	local function start_treesitter(bufnr, lang)
		local ok, err = pcall(vim.treesitter.start, bufnr, lang)
		if ok then
			set_indentexpr(bufnr, lang)
		end
		return ok, err
	end

	local function notify_install_failure(lang, reason)
		vim.notify(
			("Treesitter parser installation failed for %s: %s"):format(lang, tostring(reason)),
			vim.log.levels.WARN
		)
	end

	local function install_parser_for_buffer(bufnr, lang)
		pending_buffers[lang] = pending_buffers[lang] or {}
		pending_buffers[lang][bufnr] = true

		if install_tasks[lang] then
			return
		end

		local ok, task_or_error = pcall(ts.install, { lang })
		if not ok then
			pending_buffers[lang] = nil
			notify_install_failure(lang, task_or_error)
			return
		end

		install_tasks[lang] = task_or_error
		task_or_error:await(function(err, success)
			install_tasks[lang] = nil
			local buffers = pending_buffers[lang]
			pending_buffers[lang] = nil

			vim.schedule(function()
				if err or success ~= true then
					notify_install_failure(lang, err or "installer returned failure")
					return
				end

				for pending_bufnr in pairs(buffers or {}) do
					if
						vim.api.nvim_buf_is_valid(pending_bufnr)
						and vim.api.nvim_buf_is_loaded(pending_bufnr)
						and vim.treesitter.language.get_lang(vim.bo[pending_bufnr].filetype) == lang
					then
						start_treesitter(pending_bufnr, lang)
					end
				end
			end)
		end)
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
		callback = function(args)
			local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
			if not lang or not available_languages[lang] or lang == "verilog" then
				return
			end

			local max_filesize = 100 * 1024
			local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
			if ok and stats and stats.size > max_filesize then
				return
			end

			local parser_loaded = vim.treesitter.language.add(lang)
			if not parser_loaded then
				install_parser_for_buffer(args.buf, lang)
			else
				start_treesitter(args.buf, lang)
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
