local M = {}
function M.config()
	-- lualine config
	require("lualine").setup({
		options = {
			icons_enabled = true,
			theme = "gruvbox-material", -- based on current vim colorscheme
			-- not a big fan of fancy triangle separators
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				tabline = { "man" },
			},
			always_divide_middle = false,
		},
		sections = {
			-- left
			lualine_a = { "mode" },
			lualine_b = {
				"filename",
				"diff",
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					colored = true,
				},
			},
			lualine_c = {},
			-- right
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = {
				{
					"lsp_status",
					icon = "", -- f013
					symbols = {
						-- Standard unicode symbols to cycle through when LSP percentage is unavailable:
						spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
						-- Delimiter inserted between LSP names:
						separator = " ",
					},
					-- List of LSP names to ignore (e.g., `null-ls`):
					ignore_lsp = {},
					-- Display the LSP name
					show_name = true,
					-- Show LSP progress percentage, falling back to spinner when unavailable.
					progress_display = "percentage",
					-- Hide this component after indexing/progress completes.
					show_done = false,
				},
			},
			lualine_z = { "searchcount", "location" },
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_b = {},
			lualine_c = {},
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		extensions = {},
	})

	-- local theme = {
	--     -- this is carbonfox theme
	--     fill = 'TabLineFill',
	--     head = { fg = '#75beff', bg = '#1c1e26', style = 'italic' },
	--     current_tab = { fg = '#1c1e26', bg = '#75beff', style = 'italic' },
	--     tab = { fg = '#c5cdd9', bg = '#1c1e26', style = 'italic' },
	--     win = { fg = '#1c1e26', bg = '#75beff', style = 'italic' },
	--     tail = { fg = '#75beff', bg = '#1c1e26', style = 'italic' },
	--   }
	local theme = {
		fill = "TabLineFill",
		current_tab = "TabLine",
		tab = "NonText",
		line_sep = "Cursor",
	}
	require("tabby.tabline").set(function(line)
		return {
			line.tabs().foreach(function(tab)
				local hl = tab.is_current() and theme.current_tab or theme.tab

				-- this plugin uses the background color of the highlight groups as the foreground of the symbol for the separators
				local left_sep

				if tab.is_current() then
					left_sep = line.sep("▎", theme.line_sep, theme.current_tab)
				else
					left_sep = line.sep("▎", theme.fill, theme.fill)
				end

				return {
					left_sep,
					tab.number(),
					tab.name(),
					line.sep(" ", hl, theme.fill),
					hl = hl,
					margin = " ",
				}
			end),
			hl = theme.fill,
		}
	end)
end

return M
