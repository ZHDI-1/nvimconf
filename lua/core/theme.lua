local M = {}

local function setup_fzf_highlights()
	vim.api.nvim_set_hl(0, "FzfLuaHeaderBind", { link = "LineNr" })
	vim.api.nvim_set_hl(0, "FzfLuaPathLineNr", { link = "LineNr" })
end

function M.everforest()
	-- vim.g.everforest_background = ""
	vim.g.everforest_enable_italic = 1
	vim.g.everforest_sign_column_background = "grey"
	vim.g.everforest_spell_foreground = "colored"
	vim.g.everforest_ui_contrast = "high"
	vim.g.everforest_diagnostic_text_highlight = 1
	vim.g.everforest_diagnostic_line_highlight = 1

	vim.cmd.colorscheme("everforest")
end

function M.gruvbox_material()
	vim.g.gruvbox_material_foreground = "material"
	vim.g.gruvbox_material_transparent_background = 0
	vim.g.gruvbox_material_better_performance = 1
	vim.g.gruvbox_material_enable_bold = 1
	vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
	vim.g.gruvbox_material_diagnostic_line_highlight = 1
	vim.g.gruvbox_material_diagnostic_text_highlight = 1


	vim.cmd.colorscheme("gruvbox-material")
end

function M.kanagawa()
	vim.cmd.colorscheme("kanagawa-dragon")
end

function M.vscode()
	vim.cmd.colorscheme("vscode")
end

-- Keep the existing colorscheme plugin entry point using Everforest by default.
function M.setup()
	vim.o.background = "light"
  M.gruvbox_material()
	setup_fzf_highlights()
end

return M
