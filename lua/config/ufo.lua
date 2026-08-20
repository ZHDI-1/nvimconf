local M = {}

local function add_cpp_access_section_directive()
	vim.treesitter.query.add_directive("cpp-access-section!", function(
		match,
		_,
		_,
		predicate,
		metadata
	)
		local capture_id = predicate[2]
		local nodes = match[capture_id]
		local node = nodes and nodes[1]
		if not node then
			return
		end

		local next_section = node:next_named_sibling()
		while next_section and next_section:type() ~= "access_specifier" do
			next_section = next_section:next_named_sibling()
		end

		local start_row, start_col = node:start()
		local end_row = next_section and select(1, next_section:start())
			or select(3, node:parent():range())

		metadata[capture_id] = metadata[capture_id] or {}
		-- End at column zero so UFO keeps the next access specifier (or the
		-- class's closing brace) visible instead of including it in the fold.
		metadata[capture_id].range = { start_row, start_col, end_row, 0 }
	end, { force = true })
end

function M.config()
	add_cpp_access_section_directive()

	require("ufo").setup({
		provider_selector = function()
			return { "treesitter", "indent" }
		end,
	})
end

return M
