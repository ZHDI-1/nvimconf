local M = {}

local function detect_textwidth()
	local width = 80
	local root_dir = vim.fs.root(0, { ".clang-format", ".git", "Makefile", "CMakeLists.txt" })

	if not root_dir then
		return width
	end

	local cf_path = vim.fs.joinpath(root_dir, ".clang-format")
	if not vim.uv.fs_stat(cf_path) then
		return width
	end

	local file = io.open(cf_path, "r")
	if not file then
		return width
	end

	for line in file:lines() do
		local limit = line:match("^%s*ColumnLimit:%s*(%d+)")
		if limit then
			width = tonumber(limit)
			break
		end
	end

	file:close()
	return width
end

local function explode_line()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_get_current_line()
	local indent = line:match("^(%s*)") or ""
	local content = line:match("^%s*/%*%s*(.-)%s*%*/%s*$")

	if not content then
		return
	end

	local new_lines = {
		indent .. "/*",
		indent .. " * " .. content,
		indent .. " */",
	}

	vim.api.nvim_buf_set_lines(0, row - 1, row, false, new_lines)
	vim.api.nvim_win_set_cursor(0, { row + 1, #new_lines[2] })
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
end

local function smart_enter()
	if vim.fn.pumvisible() ~= 0 then
		return "<CR>"
	end

	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local comment_content = line:match("^%s*/%*%s*(.-)%s*%*/%s*$")

	if comment_content then
		explode_line()
		return ""
	end

	local next_char = line:sub(col + 1, col + 1)
	if next_char == "}" or next_char == ")" or next_char == "]" then
		return "<CR><Esc>O"
	end

	return "<CR>"
end

function M.setup()
	vim.opt_local.tabstop = 4
	vim.opt_local.softtabstop = 4
	vim.opt_local.shiftwidth = 4
	vim.opt_local.expandtab = true
	vim.opt_local.textwidth = detect_textwidth()
	vim.opt_local.formatoptions:append("tqc")
	vim.bo.commentstring = "/* %s */"
	vim.keymap.set("i", "<CR>", smart_enter, { buffer = true, expr = true })
end

return M
