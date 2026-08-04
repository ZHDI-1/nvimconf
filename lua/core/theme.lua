local M = {}

function M.setup()
  vim.o.background = "light"
	vim.g.everforest_background = "hard"
	vim.g.everforest_enable_italic = 1
	vim.g.everforest_sign_column_background = "grey"
	vim.g.everforest_spell_foreground = "colored"
	vim.g.everforest_ui_contrast = "high"
	vim.g.everforest_diagnostic_text_highlight = 1
	vim.g.everforest_diagnostic_line_highlight = 1
	vim.cmd("colorscheme everforest")
end

return M
