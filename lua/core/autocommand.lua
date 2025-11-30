vim.api.nvim_create_augroup('numbertoggle', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
  pattern = '*',
  group   = 'numbertoggle',
  command = 'if &nu && mode() != "i" | set rnu | endif',
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  pattern = '*',
  group = 'numbertoggle',
  command = 'if &nu | set nornu | endif',
})

vim.api.nvim_create_augroup('autosave', { clear = true })
vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertEnter', 'InsertLeave' }, {
  pattern  = '*',
  group    = 'autosave',
  callback = function(args)
    local win_conf = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win())
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.o.buftype == '' and
        vim.o.readonly == false and
        win_conf.relative == "" and
        vim.api.nvim_get_option_value("modified", { buf = bufnr }) and
        vim.api.nvim_buf_get_name(0) ~= "" and
        vim.fn.expand('%:t') ~= 'wezterm.lua' and
        vim.fn.expand('%:t') ~= 'alacritty.toml' then
      vim.cmd('w')
    end
  end
})

vim.api.nvim_create_augroup('indentForConfigFile', { clear = true })
vim.api.nvim_create_autocmd('Filetype', {
  pattern = {
    'css', 'xcss', 'html', 'xhtml', 'javascript', 'typescript', 'yaml', 'lua', 'jsx', 'tsx', 'typescriptreact',
    'javascriptreact', 'markdown', 'md', 'xml', 'json', 'sshconfig', 'lisp','verilog','systemverilog' },
  group = 'indentForConfigFile',
  callback = function()
    vim.opt_local.tabstop     = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth  = 2
  end
})

vim.api.nvim_create_augroup('change_comment_string', { clear = true })
vim.api.nvim_create_autocmd('Filetype', {
  group = 'change_comment_string',
  pattern = { 'asm' },
  callback = function()
    vim.api.nvim_set_option_value("commentstring", "/*%s*/", {
      buf = 0
    })
  end
})

-- vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'},{
--   group = vim.api.nvim_create_augroup('TS_fold_workground', {clear = true}),
--   callback = function ()
--     vim.opt.foldmethod  = 'expr'
--     vim.opt.foldexpr    = 'nvim_treesitter#foldexpr()'
--   end
-- }
-- )
-- local function get_root_dir_for_session()
--   local buf = vim.api.nvim_get_current_buf()
--   local clients = vim.lsp.get_clients({ bufnr = buf })
--   if #clients > 0 then
--     return clients[1].root_dir
--   end
-- end
-- vim.api.nvim_create_augroup('session_manage', { clear = true })
-- vim.api.nvim_create_autocmd({ 'VimLeave' }, {
--   group = 'session_manage',
--   callback = function()
--     local root_dir = get_root_dir_for_session()
--     if root_dir then
--       vim.cmd('cd ' .. root_dir)
--       local session_file = root_dir .. '/Session.vim'
--       if vim.fn.filereadable(session_file) == 1 then
--         vim.cmd("mks!")
--       end
--     end
--   end
-- })
--
-- vim.api.nvim_create_autocmd({ 'VimEnter' }, {
--   group = 'session_manage',
--   callback = function()
--     local function get_root_dir_for_session()
--       local buf = vim.api.nvim_get_current_buf()
--       local clients = vim.lsp.get_clients({ bufnr = buf })
--       if #clients > 0 then
--         return clients[1].root_dir
--       end
--     end
--     local root_dir = get_root_dir_for_session()
--     if root_dir then
--       vim.cmd('cd ' .. root_dir)
--
--       -- Check if Session.vim exists in root directory
--       local session_file = root_dir .. '/Session.vim'
--       if vim.fn.filereadable(session_file) == 1 then
--         -- Source the session file
--         vim.cmd('source ' .. session_file)
--       end
--     end
--   end
-- })
--
--
-- Ensure the augroup exists and is clear
-- vim.api.nvim_create_augroup('simple_session_manage', { clear = true })

-- Function to safely get project root using LSP (optional, can be adapted or removed if not needed for loading)
-- Note: This function is less critical in the revised approach but kept for potential future use or adaptation.
local function get_lsp_project_root(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  -- Ensure LSP is ready, might need vim.schedule if called too early
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  if #clients > 0 then
    -- Prefer clients with a known root_dir
    for _, client in ipairs(clients) do
      if client and client.root_dir then
        return client.root_dir
      end
    end
  end
  return nil -- No suitable LSP client found for this buffer
end

-- Autocommand to Load Session on Neovim Start
-- vim.api.nvim_create_autocmd({ 'VimEnter' }, {
--   group = 'simple_session_manage',
--   pattern = '*', -- Apply broadly on enter
--   callback = function(args)
--     -- We only want this to run once on startup, not for nested :edit calls etc.
--     -- Using a guard or checking vim.v.vim_did_enter seems appropriate.
--     if vim.v.vim_did_enter == 1 then
--       local cwd = vim.fn.getcwd()
--       local session_file = cwd .. '/Session.vim'
--       local session_path_escaped = vim.fn.fnameescape(session_file)
--
--       -- Check if Session.vim exists in the current working directory
--       if vim.fn.filereadable(session_file) == 1 then
--         -- Use pcall to catch potential errors during sourcing (e.g., corrupted session file)
--         vim.cmd('source ' .. session_path_escaped)
--         -- local ok, err = pcall(vim.cmd, 'source ' .. session_path_escaped)
--         -- if ok then
--         --   print("Session loaded from: " .. session_file)
--         -- else
--         --   print("Error loading session from " .. session_file .. ": " .. tostring(err))
--         --   -- Decide if you want to do anything else on error, like clearing the buffer list
--         -- end
--         -- Potentially restore the view or cursor position if needed,
--         -- though 'source Session.vim' often handles this.
--       else
--          -- Optional: Handle case where no session file exists (e.g., print a message)
--          -- print("No session file found at: " .. session_file)
--       end
--
--       -- Optional: If starting Neovim with a specific file, you *could* try to
--       -- determine its project root via LSP and load that session instead of CWD.
--       -- This adds complexity due to LSP startup timing. Example idea:
--       -- if vim.fn.argc() > 0 then
--       --   local first_file_buf = vim.fn.bufnr(vim.v.argv[1])
--       --   vim.schedule(function() -- Defer LSP check slightly
--       --      local file_root = get_lsp_project_root(first_file_buf)
--       --      if file_root and file_root ~= cwd then
--       --          local file_session = file_root .. '/Session.vim'
--       --          -- ... load this session instead ...
--       --      end
--       --   end)
--       -- end
--     end
--   end,
--   once = true, -- Ensures this VimEnter callback only runs once per Neovim session
--   nested = true,
-- })
--
-- -- Autocommand to Save Session on Neovim Exit
-- vim.api.nvim_create_autocmd({ 'VimLeavePre' }, { -- Use VimLeavePre to run before Neovim truly exits
--   group = 'simple_session_manage',
--   pattern = '*', -- Apply broadly on leave
--   callback = function()
--     local cwd = vim.fn.getcwd()
--     local session_file = cwd .. '/Session.vim'
--     local session_path_escaped = vim.fn.fnameescape(session_file)
--
--     -- Check if a Session.vim file *already exists* in the current working directory
--     -- This prevents creating Session.vim in random directories if you quit outside a project.
--     -- If you *want* to create new session files automatically, remove this check.
--     if vim.fn.filereadable(session_file) == 1 then
--       -- Use pcall for safety, though mksession is usually robust
--       --
--       vim.cmd("mks!")
--       -- local ok, err = pcall(vim.cmd, 'mksession! ' .. session_path_escaped)
--       -- if ok then
--       --   -- Optional: print message
--       --   -- print("Session saved to: " .. session_file)
--       -- else
--       --   print("Error saving session to " .. session_file .. ": " .. tostring(err))
--       -- end
--     else
--       -- Optional: If you want to *create* a session file if one doesn't exist in CWD:
--       -- vim.cmd('mksession! ' .. session_path_escaped)
--       -- print("Created and saved session: " .. session_file)
--     end
--   end
-- })
--

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'help',
  callback = function()
    vim.keymap.set('n', 'gO', function()
      local fname = vim.fn.expand('%:t')
      local lines = vim.fn.getline(1, '$')
      local toc = {}
      for _, line in ipairs(lines) do
        if line:match('^%S') then
          local lnum = vim.fn.line('.')
          table.insert(toc, fname .. '|' .. lnum .. '| ' .. line)
        end
      end
      vim.fn.setqflist({}, ' ', {
        title = 'TOC',
        lines = toc,
      })
      vim.cmd('copen')
    end, { buffer = true })
  end
})
