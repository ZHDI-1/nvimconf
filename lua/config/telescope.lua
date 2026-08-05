local M = {}
function M.config()
	local actions = require("fzf-lua").actions
	require("fzf-lua").setup({
		"ivy",
		winopts = {
			height = 1, -- window height
		},
		fzf_colors = true,
		keymap = {
			builtin = {
				["<M-Esc>"] = "hide", -- hide fzf-lua, `:FzfLua resume` to continue
				["<F1>"] = "toggle-help",
				["<F2>"] = "toggle-fullscreen",
				-- Only valid with the 'builtin' previewer
				["<F3>"] = "toggle-preview-wrap",
				["<F4>"] = "toggle-preview",
				-- Rotate preview clockwise/counter-clockwise
				["<F5>"] = "toggle-preview-ccw",
				["<F6>"] = "toggle-preview-cw",
				-- `ts-ctx` binds require `nvim-treesitter-context`
				["<F7>"] = "toggle-preview-ts-ctx",
				["<F8>"] = "preview-ts-ctx-dec",
				["<F9>"] = "preview-ts-ctx-inc",
				["<C-r>"] = "preview-reset",
				["<C-d>"] = "preview-page-down",
				["<C-u>"] = "preview-page-up",
				-- ["<C-j>"] = "preview-down",
				["<C-k>"] = false,
			},
			fzf = {
				-- fzf '--bind=' options
				-- true,        -- uncomment to inherit all the below in your custom config
				["ctrl-z"] = "abort",
				-- ["ctrl-f"] = "half-page-down",
				-- ["ctrl-b"] = "half-page-up",

				["ctrl-a"] = "beginning-of-line",
				["ctrl-e"] = "end-of-line",
				["ctrl-b"] = "backward-char",
				["ctrl-f"] = "forward-char",
				["ctrl-k"] = "kill-line",

				["alt-q"] = "select-all+accept",
				["ctrl-y"] = "toggle-down",
				["alt-a"] = "toggle-all",
				["alt-g"] = "first",
				["alt-G"] = "last",
				-- Only valid with fzf previewers (bat/cat/git/etc)
				["f3"] = "toggle-preview-wrap",
				["f4"] = "toggle-preview",
			},
		},
		files = {
			cwd_header = true,
			actions = {
				["ctrl-q"] = actions.file_sel_to_qf,
				["alt-q"] = actions.file_sel_to_qf,
			},
			follow = true,
		},
		buffers = {
			actions = {
				["ctrl-w"] = { fn = actions.buf_del, reload = true },
				["ctrl-q"] = actions.buf_sel_to_qf, -- Use buffer specific action for buffers
				["alt-q"] = actions.buf_sel_to_qf, -- Use buffer specific action for buffers
			},
		},
		grep = {
			rg_opts = "--column --line-number --no-heading --color=always "
				.. "--smart-case --max-columns=4096 --no-messages -e",
			actions = {
				["ctrl-q"] = actions.file_sel_to_qf,
				["alt-q"] = actions.file_sel_to_qf,
			},
			follow = true,
		},
		marks = {
			actions = {
				["ctrl-w"] = {
					fn = actions.mark_del,
					reload = true,
				},
			},
		},
	})
end

return M
