-- GLOBAL helper (must be global for <Cmd>)
_G.KernelKeys = _G.KernelKeys or {}

-- HELPER: Find non-empty line searching upwards or downwards
local function find_directive(buf, start_line, direction, pattern)
    local limit = 5 -- How many empty lines to skip before giving up?
    local current = start_line
    local count = 0
    
    while count < limit do
        -- Bounds check
        if current < 0 or current >= vim.api.nvim_buf_line_count(buf) then return nil end
        
        local line = vim.api.nvim_buf_get_lines(buf, current, current + 1, false)[1]
        
        -- Found the directive?
        if line:match(pattern) then
            return current
        end
        
        current = current + direction
        count = count + 1
    end
    return nil
end

_G.KernelKeys.toggle_if_0 = function(mode)
    local buf = vim.api.nvim_get_current_buf()

    -- === VISUAL MODE LOGIC ===
    if mode == "v" then
        -- 1. Get Visual Selection Range
        local s_start = vim.fn.getpos("v")[2] - 1
        local s_end = vim.fn.getpos(".")[2] - 1
        if s_start > s_end then s_start, s_end = s_end, s_start end

        -- 2. Check for existing wrappers (Look slightly outside the selection)
        -- Look UP for "#if 0"
        local if_line = find_directive(buf, s_start + 1, -1, "^%s*#if%s+0%s*$")
        -- Look DOWN for "#endif"
        local endif_line = find_directive(buf, s_end - 1, 1, "^%s*#endif%s*$")

        if if_line and endif_line then
            -- REMOVE THEM (Delete bottom first to preserve top line index)
            vim.api.nvim_buf_set_lines(buf, endif_line, endif_line + 1, false, {})
            vim.api.nvim_buf_set_lines(buf, if_line, if_line + 1, false, {})
        else
            -- ADD THEM
            vim.api.nvim_buf_set_lines(buf, s_end + 1, s_end + 1, false, { "#endif" })
            vim.api.nvim_buf_set_lines(buf, s_start, s_start, false, { "#if 0" })
        end
        
        -- Exit visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', false)

    -- === NORMAL MODE LOGIC ===
    else
        local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
        local node = vim.treesitter.get_node()
        local found_if = nil
        
        -- Walk UP the tree (Leaf -> Root). 
        -- This is NOT expensive. Even deep code is usually <20 nodes to root.
        while node do
            if node:type() == "preproc_if" then
                -- We found a preprocessor block. Check if it is "#if 0"
                local text = vim.treesitter.get_node_text(node, buf)
                if text:match("^%s*#if%s+0") then
                    found_if = node
                    break
                end
            end
            node = node:parent()
        end

        if found_if then
            -- UNWRAP: We found we are inside a #if 0 block. Delete the directive lines.
            local s_row, _, e_row, _ = found_if:range()
            -- Note: Tree-sitter ranges include the #endif line.
            -- e_row is the line index of #endif. s_row is #if 0.
            
            -- Delete #endif first
            vim.api.nvim_buf_set_lines(buf, e_row, e_row + 1, false, {})
            -- Delete #if 0
            vim.api.nvim_buf_set_lines(buf, s_row, s_row + 1, false, {})
        else
            -- WRAP: No surrounding #if 0 found. Wrap the CURRENT LINE.
            vim.api.nvim_buf_set_lines(buf, cursor_row + 1, cursor_row + 1, false, { "#endif" })
            vim.api.nvim_buf_set_lines(buf, cursor_row, cursor_row, false, { "#if 0" })
        end
    end
end

-- BINDINGS
-- Visual Mode
vim.keymap.set("x", "<leader>ci", function() _G.KernelKeys.toggle_if_0("v") end, { desc = "Toggle #if 0 (Visual)", buffer = true })
-- Normal Mode
vim.keymap.set("n", "<leader>ci", function() _G.KernelKeys.toggle_if_0("n") end, { desc = "Toggle #if 0 (Node/Line)", buffer = true })

-- A. The "Worker" function (Safe to edit buffer here)
function _G.KernelKeys.explode_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    
    -- Capture indentation and content
    local indent = line:match("^(%s*)") or ""
    local content = line:match("^%s*/%*%s*(.-)%s*%*/%s*$")
    
    if not content then return end

    -- Construct the 3-line block
    local new_lines = {
        indent .. "/*",
        indent .. " * " .. content,
        indent .. " */"
    }

    -- Apply changes
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, new_lines)
    
    -- Move cursor to end of the middle line
    vim.api.nvim_win_set_cursor(0, {row + 1, #new_lines[2]})
    
    -- TRIGGER ENTER: This simulates pressing Enter *now* that we are in the block.
    -- This triggers 'formatoptions' to insert the next ' * ' automatically.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), 'n', false)
end

local function smart_enter()
    if vim.fn.pumvisible() ~= 0 then
        return "<CR>"
    end

    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1], cursor[2] -- col is 0-indexed

    -- Detect if we are inside a single-line comment: /* ... */
    local comment_content = line:match("^%s*/%*%s*(.-)%s*%*/%s*$")
    
    if comment_content then
      return "<Cmd>lua _G.KernelKeys.explode_line()<CR>"
    end

    -- PRIORITY 3: Your Brace Expansion Hack
    -- Check the character *after* the cursor
    local next_char = line:sub(col + 1, col + 1)
    if next_char == '}' or next_char == ')' or next_char == ']' then
        -- Expands {|} to:
        -- {
        --   |
        -- }
        return "<CR><Esc>O"
    end

    -- PRIORITY 4: Standard Enter
    return "<CR>"
end

vim.keymap.set('i', '<CR>', smart_enter, { expr = true })

local function fix_kernel_comment()
    -- 1. Tree-sitter node check
    local node = vim.treesitter.get_node()
    if not node then return end

    -- Walk up to find 'comment'
    while node do
        if node:type() == 'comment' then break end
        node = node:parent()
    end
    if not node then 
        vim.notify("Not inside a comment!", vim.log.levels.WARN)
        return 
    end

    -- 2. Get Range & INDENTATION
    local s_row, _, e_row, _ = node:range()
    
    -- Grab the first line of the comment to copy its indentation perfectly
    local first_line = vim.api.nvim_buf_get_lines(0, s_row, s_row + 1, false)[1]
    local indent = first_line:match("^(%s*)") or "" -- Captures tabs or spaces

    -- 3. Extract text
    local lines = vim.api.nvim_buf_get_lines(0, s_row, e_row + 1, false)
    local content = {}
    for _, line in ipairs(lines) do
        local clean = line:gsub("/%*", ""):gsub("%*/", "")
        clean = clean:gsub("^%s*%*%s?", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if clean ~= "" then
            table.insert(content, clean)
        end
    end

    -- 4. Rebuild with PRESERVED INDENT
    local new_lines = { indent .. "/*" }
    for _, text in ipairs(content) do
        table.insert(new_lines, indent .. " * " .. text)
    end
    table.insert(new_lines, indent .. " */")

    -- 5. Apply
    vim.api.nvim_buf_set_lines(0, s_row, e_row + 1, false, new_lines)
    
    -- Move cursor to end
    vim.api.nvim_win_set_cursor(0, {s_row + #new_lines - 1, #new_lines[#new_lines]})
end

vim.keymap.set('n', '<leader>cf', fix_kernel_comment, { desc = "Fix/Format Kernel Comment" })


local width = 80 
local root_dir = vim.fs.root(0, {'.clang-format', '.git', 'Makefile', 'CMakeLists.txt'})

if root_dir then
    local cf_path = vim.fs.joinpath(root_dir, '.clang-format')
    
    -- 3. Check if file exists and parse it
    -- (vim.uv.fs_stat is non-blocking/efficient check)
    if vim.uv.fs_stat(cf_path) then
        local file = io.open(cf_path, "r")
        if file then
            for line in file:lines() do
                -- Regex: "ColumnLimit: 120"
                local limit = line:match("^%s*ColumnLimit:%s*(%d+)")
                if limit then
                    width = tonumber(limit)
                    break
                end
            end
            file:close()
        end
    end
end

-- 4. Apply the setting
vim.opt_local.textwidth = width
vim.opt_local.formatoptions:append("tqc")
vim.bo.commentstring = "/* %s */"
