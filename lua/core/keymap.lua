-- general
-- vim.keymap.set({'n', 'i', 'c', 'v', 'o', 's'}, '<C-f>', '<Esc>', { noremap = true})
vim.g.mapleader = ' '
-- vim.keymap.set({ 'n', 'v' }, '<Space>', 'Nop', { noremap = true })

vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<C-k>', '<Right><Esc>d$a')


vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- terminal
vim.keymap.set('t', '<C-[>', '<C-\\><C-N>', { noremap = true })
-- vim.keymap.set('t', '<ESC>', '<C-\\><C-N>', { noremap = true })

-- fzf-lua
local fzf_builtin = require('fzf-lua')
vim.keymap.set('n', '<leader>ff', fzf_builtin.files, {})
vim.keymap.set('n', '<leader>fg', fzf_builtin.live_grep, {})
vim.keymap.set('n', '<leader>e', fzf_builtin.buffers, {})
vim.keymap.set('n', '<leader>fcg', fzf_builtin.lgrep_curbuf, {})
vim.keymap.set('n', '<leader>fl', fzf_builtin.lines, {})
-- vim.keymap.set('n', '<leader>fcl', fzf_builtin.lines, {})
-- vim.keymap.set('n', '<leader>ft', fzf_builtin.tmux_buffers, {})
vim.keymap.set('n', '<leader>ft', fzf_builtin.tabs, {})
vim.keymap.set('n', '<leader>fs', fzf_builtin.lsp_live_workspace_symbols, {})
vim.keymap.set('n', '<leader>fr', fzf_builtin.lsp_references, {})
vim.keymap.set('n', '<leader>fi', fzf_builtin.lsp_incoming_calls, {})
vim.keymap.set('n', '<leader>fo', fzf_builtin.lsp_outgoing_calls, {})
vim.keymap.set('n', 'gr', fzf_builtin.lsp_references, {})
vim.keymap.set('n', '<leader>fm', fzf_builtin.marks, {})

-- tabs
vim.keymap.set('n', '<leader>tn', ':tabnext<CR>', { noremap = true })
vim.keymap.set('n', '<leader>tp', ':tabprevious<CR>', { noremap = true })
vim.keymap.set('n', '<leader>to', ':tabnew<CR>', { noremap = true })
vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tmp", ":-tabmove<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tmn", ":+tabmove<CR>", { noremap = true })
vim.keymap.set('n', '<leader>tr', ':Tabby rename_tab ', { noremap = true })


-- movelines
-- dont think i need this anymore
-- vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { noremap = true })
-- vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { noremap = true })
-- vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true })
-- vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true })
-- vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true })
-- vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true })

-- copy to clipboard
vim.keymap.set('n', "<leader>y", '"+y', { noremap = true })
vim.keymap.set('v', "<leader>y", '"+y', { noremap = true })
vim.keymap.set('n', "<leader>p", '"+p', { noremap = true })
vim.keymap.set('v', "<leader>p", '"+p', { noremap = true })

-- windows
-- vim.keymap.set('n', '<A-->', '<c-w>-')
-- vim.keymap.set('n', '<A-=>', '<c-w>+')
-- vim.keymap.set('n', '<A-0>', '<c-w>>')
-- vim.keymap.set('n', '<A-9>', '<c-w><')
-- vim.keymap.set('i', '<A-->', '<Esc><c-w>-a')
-- vim.keymap.set('i', '<A-=>', '<Esc><c-w>+a')
-- vim.keymap.set('i', '<A-0>', '<Esc><c-w><a')
-- vim.keymap.set('i', '<A-9>', '<Esc><c-w>>a')

-- search
vim.keymap.set('n', '/', '/\\v')
-- vim.keymap.set('i', '<a-/>', '<Esc>/\\v')
vim.keymap.set('n', '<a-r>', ':s/\\v//g<Left><Left><Left>')
vim.keymap.set('v', '<a-r>', ':s/\\v//g<Left><Left><Left>')
-- vim.keymap.set('i', '<a-r>', '<Esc>:s/\\v//g<Left><Left><Left>')

-- touble
vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle('diagnostics') end)
vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end)
vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("symbols") end)
-- vim.keymap.set("n", "gr", function() require("trouble").toggle("lsp_references") end)

-- auto pair
vim.keymap.set('i', '{', '{}<Left>')
vim.keymap.set('i', '[', '[]<Left>')
vim.keymap.set('i', '(', '()<Left>')
-- vim.keymap.set('i', '\'', function()
--   local line = vim.api.nvim_get_current_line()
--   local cursor = vim.api.nvim_win_get_cursor(0)[2]
--   local prev = line:sub(cursor - 1, cursor - 1)
--   if prev == '\'' then
--     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('\'', true, false, true), 'n', false)
--   else
--     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('\'\'<Left>', true, false, true), 'n', false)
--   end
-- end
-- )
vim.keymap.set('i', '"', '""<Left>')


vim.api.nvim_create_augroup('other_pairs', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'other_pairs',
  pattern = '*',
  callback = function()
    if not vim.tbl_contains({ 'verilog', 'systemverilog' }, vim.bo.filetype) then
      vim.keymap.set('i', '\'', '\'\'<Left>', { buffer = true, silent = true })
    end
  end
})
-- vim.keymap.set('i', '<', '<><Left>')
vim.keymap.set('i', '<CR>', function()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2]
  local next = line:sub(cursor + 1, cursor + 1)
  if next == '}' or next == ')' or next == ']' then
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR><Esc>O', true, false, true), 'n', false)
    return '<CR><Esc>O'
  else
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
    return '<CR>'
  end
end
, { expr = true })
vim.keymap.set('i', '<Tab>', function()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2]
  local pair_table = { '\'', '"', '}', ']', ')', '>', }

  local function contains(tab, val)
    for _, v in ipairs(tab) do
      if v == val then
        return true
      end
    end
    return false
  end
  if (line:len() - cursor) == 0 then
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
    return '<Tab>'
  end

  if contains(pair_table, line:sub(cursor + 1, cursor + 1)) then
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Right>', true, false, true), 'n', false)
    return '<Right>'
  else
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
    return '<Tab>'
  end
end
, { expr = true })
vim.keymap.set('i', '<BS>', function()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2]
  local current = line:sub(cursor, cursor)
  local next = line:sub(cursor + 1, cursor + 1)
  local pair_table_r = { '\'', '"', '}', ']', ')', '>' }
  local pair_table_l = { '\'', '"', '{', '[', '(', '<' }
  local function contains(tab, val)
    for i, v in ipairs(tab) do
      if v == val then
        return true, i
      end
    end
    return false, 0
  end
  local function match_paris(current_char, next_char)
    local current_is_pair, current_index = contains(pair_table_l, current_char)
    local next_is_pair, next_index = contains(pair_table_r, next_char)
    if current_is_pair and next_is_pair and current_index == next_index then
      return true
    else
      return false
    end
  end
  if match_paris(current, next) then
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Right><BS><BS>', true, false, true), 'n', false)
    return '<Right><BS><BS>'
  else
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<BS>', true, false, true), 'n', false)
    return '<BS>'
  end
end
, { expr = true })

-- ts repeat
local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

-- fold
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)


local function navigate(direction)
  local current_win = vim.fn.winnr()
  local windows_count = vim.fn.winnr('$')

  -- Try to navigate to vim split
  vim.cmd('wincmd ' .. direction)

  -- If we didn't move (hit edge or only one window)
  if current_win == vim.fn.winnr() then
    -- If we only have one window or we hit the edge
    local tmux_direction = {
      h = 'L',
      j = 'D',
      k = 'U',
      l = 'R'
    }
    -- Send tmux command to switch pane
    vim.fn.system('tmux select-pane -' .. tmux_direction[direction])
  end
end

-- Set up keybindings
vim.keymap.set('n', '<C-w>h', function() navigate('h') end)
vim.keymap.set('n', '<C-w>j', function() navigate('j') end)
vim.keymap.set('n', '<C-w>k', function() navigate('k') end)
vim.keymap.set('n', '<C-w>l', function() navigate('l') end)

-- Optional: More direct bindings if you prefer
-- vim.keymap.set('n', '<C-h>', function() navigate('h') end)
-- vim.keymap.set('n', '<C-j>', function() navigate('j') end)
-- vim.keymap.set('n', '<C-k>', function() navigate('k') end)
-- vim.keymap.set('n', '<C-l>', function() navigate('l') end)
