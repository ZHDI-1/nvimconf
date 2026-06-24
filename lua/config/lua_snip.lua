local M = {}

function M.config()
	local ls = require("luasnip")
	ls.config.setup({ enable_autosnippets = true })
	local s = ls.snippet
	local t = ls.text_node
	local i = ls.insert_node
	-- The condition logic comes from LuaSnip extras
	local conds = require("luasnip.extras.expand_conditions")

	local c_block_comment = s({
		trig = "/*",
		snippetType = "autosnippet",
	}, {
		t({ "/*", " * " }),
		i(1),
		t({ "", " */" }),
	}, {
		-- This condition ensures it ONLY triggers if "//"
		-- is the first non-whitespace text on the line.
		condition = conds.line_begin,
	})

	local c_inline_comment = s({
		trig = "//",
		snippetType = "autosnippet",
	}, {
		t("/* "), -- Just open
		i(1), -- Cursor in the middle
		t(" */"), -- Close immediately
	}, {
		condition = conds.line_begin,
	})

	-- Add to C and C++
	ls.add_snippets("c", { c_block_comment, c_inline_comment })
	ls.add_snippets("cpp", { c_block_comment, c_inline_comment })
end

return M
