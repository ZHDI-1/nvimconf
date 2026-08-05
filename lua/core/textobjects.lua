local M = {}

local move = require("nvim-treesitter-textobjects.move")
local repeatable_move = require("nvim-treesitter-textobjects.repeatable_move")
local select = require("nvim-treesitter-textobjects.select")
local shared = require("nvim-treesitter-textobjects.shared")
local swap = require("nvim-treesitter-textobjects.swap")

local TEXTOBJECT_QUERY_GROUP = "textobjects"
local FUNCTION_QUERY = "@function.outer"
local CLASS_QUERY = "@class.outer"
local MOVEMENT_MODES = { "n", "x", "o" }

local context_aware_motions = {
	["[["] = {
		method = "goto_previous_start",
		desc = "Previous function/class start",
	},
	["[]"] = {
		method = "goto_previous_end",
		desc = "Previous function/class end",
	},
	["]]"] = {
		method = "goto_next_start",
		desc = "Next function/class start",
	},
	["]["] = {
		method = "goto_next_end",
		desc = "Next function/class end",
	},
}

local function parser_is_available()
	local ok, parser = pcall(vim.treesitter.get_parser, 0)
	return ok and parser ~= nil
end

local function cursor_is_inside(query_string)
	local ok, range = pcall(shared.textobject_at_point, query_string, TEXTOBJECT_QUERY_GROUP)
	return ok and range ~= nil
end

local function queries_for_cursor()
	-- nvim-treesitter-textobjects has an empty-table/no-parser path which is
	-- truthy to Lua and later causes its score comparison to use nil values.
	if not parser_is_available() then
		return nil
	end

	-- A function takes precedence over its containing class. This keeps the
	-- four bracket motions focused on the smallest meaningful current scope.
	if cursor_is_inside(FUNCTION_QUERY) then
		return FUNCTION_QUERY
	end

	if cursor_is_inside(CLASS_QUERY) then
		return CLASS_QUERY
	end

	-- Outside either scope, the textobject move implementation compares both
	-- captures and chooses the closest start/end for the requested direction.
	return { FUNCTION_QUERY, CLASS_QUERY }
end

local function move_if_parser_available(method, query_strings, query_group)
	if parser_is_available() then
		move[method](query_strings, query_group)
	end
end

local function move_in_current_context(method)
	local query_strings = queries_for_cursor()
	if not query_strings then
		return
	end

	move_if_parser_available(method, query_strings, TEXTOBJECT_QUERY_GROUP)
end

local function map_context_aware_motion(lhs, motion)
	vim.keymap.set(MOVEMENT_MODES, lhs, function()
		move_in_current_context(motion.method)
	end, { desc = motion.desc })
end

local function map_selection(lhs, query_string)
	vim.keymap.set({ "x", "o" }, lhs, function()
		select.select_textobject(query_string, TEXTOBJECT_QUERY_GROUP)
	end)
end

function M.setup()
	map_selection("af", "@function.outer")
	map_selection("if", "@function.inner")
	map_selection("ac", "@class.outer")
	map_selection("ic", "@class.inner")
	map_selection("aa", "@assignment.outer")
	map_selection("ia", "@assignment.inner")

	vim.keymap.set("n", "<leader>a", function()
		swap.swap_next("@parameter.inner", TEXTOBJECT_QUERY_GROUP)
	end)
	vim.keymap.set("n", "<leader>A", function()
		swap.swap_previous("@parameter.inner", TEXTOBJECT_QUERY_GROUP)
	end)

	for lhs, motion in pairs(context_aware_motions) do
		map_context_aware_motion(lhs, motion)
	end

	vim.keymap.set(MOVEMENT_MODES, "]o", function()
		move_if_parser_available("goto_next_start", { "@loop.inner", "@loop.outer" }, TEXTOBJECT_QUERY_GROUP)
	end)
	vim.keymap.set(MOVEMENT_MODES, "]s", function()
		move_if_parser_available("goto_next_start", "@local.scope", "locals")
	end)
	vim.keymap.set(MOVEMENT_MODES, "]z", function()
		move_if_parser_available("goto_next_start", "@fold", "folds")
	end)
	vim.keymap.set(MOVEMENT_MODES, "]d", function()
		move_if_parser_available("goto_next", "@conditional.outer", TEXTOBJECT_QUERY_GROUP)
	end)
	vim.keymap.set(MOVEMENT_MODES, "[d", function()
		move_if_parser_available("goto_previous", "@conditional.outer", TEXTOBJECT_QUERY_GROUP)
	end)

	vim.keymap.set(MOVEMENT_MODES, ";", function()
		repeatable_move.repeat_last_move_next()
	end)
	vim.keymap.set(MOVEMENT_MODES, ",", function()
		repeatable_move.repeat_last_move_previous()
	end)

	vim.keymap.set(MOVEMENT_MODES, "f", function()
		return repeatable_move.builtin_f_expr()
	end, { expr = true })
	vim.keymap.set(MOVEMENT_MODES, "F", function()
		return repeatable_move.builtin_F_expr()
	end, { expr = true })
	vim.keymap.set(MOVEMENT_MODES, "t", function()
		return repeatable_move.builtin_t_expr()
	end, { expr = true })
	vim.keymap.set(MOVEMENT_MODES, "T", function()
		return repeatable_move.builtin_T_expr()
	end, { expr = true })
end

return M
