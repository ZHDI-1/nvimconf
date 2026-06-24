local M = {}

function M.config()
	require("ufo").setup({
		provider_selector = function()
			return { "treesitter", "indent" }
		end,
	})
end

return M
