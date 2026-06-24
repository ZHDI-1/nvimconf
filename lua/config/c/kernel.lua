local M = {}

local function find_directive(buf, start_line, direction, pattern)
	local limit = 5
	local current = start_line
	local count = 0

	while count < limit do
		if current < 0 or current >= vim.api.nvim_buf_line_count(buf) then
			return nil
		end

		local line = vim.api.nvim_buf_get_lines(buf, current, current + 1, false)[1]
		if line:match(pattern) then
			return current
		end

		current = current + direction
		count = count + 1
	end

	return nil
end

local function toggle_if_0(mode)
	local buf = vim.api.nvim_get_current_buf()

	if mode == "v" then
		local s_start = vim.fn.getpos("v")[2] - 1
		local s_end = vim.fn.getpos(".")[2] - 1
		if s_start > s_end then
			s_start, s_end = s_end, s_start
		end

		local if_line = find_directive(buf, s_start + 1, -1, "^%s*#if%s+0%s*$")
		local endif_line = find_directive(buf, s_end - 1, 1, "^%s*#endif%s*$")

		if if_line and endif_line then
			vim.api.nvim_buf_set_lines(buf, endif_line, endif_line + 1, false, {})
			vim.api.nvim_buf_set_lines(buf, if_line, if_line + 1, false, {})
		else
			vim.api.nvim_buf_set_lines(buf, s_end + 1, s_end + 1, false, { "#endif" })
			vim.api.nvim_buf_set_lines(buf, s_start, s_start, false, { "#if 0" })
		end

		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		return
	end

	local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local node = vim.treesitter.get_node()
	local found_if = nil

	while node do
		if node:type() == "preproc_if" then
			local text = vim.treesitter.get_node_text(node, buf)
			if text:match("^%s*#if%s+0") then
				found_if = node
				break
			end
		end
		node = node:parent()
	end

	if found_if then
		local s_row, _, e_row, _ = found_if:range()
		vim.api.nvim_buf_set_lines(buf, e_row, e_row + 1, false, {})
		vim.api.nvim_buf_set_lines(buf, s_row, s_row + 1, false, {})
	else
		vim.api.nvim_buf_set_lines(buf, cursor_row + 1, cursor_row + 1, false, { "#endif" })
		vim.api.nvim_buf_set_lines(buf, cursor_row, cursor_row, false, { "#if 0" })
	end
end

local function fix_kernel_comment()
	local node = vim.treesitter.get_node()
	if not node then
		return
	end

	while node do
		if node:type() == "comment" then
			break
		end
		node = node:parent()
	end

	if not node then
		vim.notify("Not inside a comment!", vim.log.levels.WARN)
		return
	end

	local s_row, _, e_row, _ = node:range()
	local first_line = vim.api.nvim_buf_get_lines(0, s_row, s_row + 1, false)[1]
	local indent = first_line:match("^(%s*)") or ""
	local lines = vim.api.nvim_buf_get_lines(0, s_row, e_row + 1, false)
	local content = {}

	for _, line in ipairs(lines) do
		local clean = line:gsub("/%*", ""):gsub("%*/", "")
		clean = clean:gsub("^%s*%*%s?", ""):gsub("^%s+", ""):gsub("%s+$", "")
		if clean ~= "" then
			table.insert(content, clean)
		end
	end

	local new_lines = { indent .. "/*" }
	for _, text in ipairs(content) do
		table.insert(new_lines, indent .. " * " .. text)
	end
	table.insert(new_lines, indent .. " */")

	vim.api.nvim_buf_set_lines(0, s_row, e_row + 1, false, new_lines)
	vim.api.nvim_win_set_cursor(0, { s_row + #new_lines - 1, #new_lines[#new_lines] })
end

function M.setup()
	vim.opt_local.expandtab = false
	vim.opt_local.tabstop = 8
	vim.opt_local.softtabstop = 8
	vim.opt_local.shiftwidth = 8

	vim.keymap.set("x", "<leader>ci", function()
		toggle_if_0("v")
	end, { buffer = true, desc = "Toggle #if 0 (Visual)" })

	vim.keymap.set("n", "<leader>ci", function()
		toggle_if_0("n")
	end, { buffer = true, desc = "Toggle #if 0 (Node/Line)" })

	vim.keymap.set("n", "<leader>cf", fix_kernel_comment, {
		buffer = true,
		desc = "Fix/Format Kernel Comment",
	})
end

return M
