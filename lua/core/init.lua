-- TODO:
-- session manage with au/root dir detect
-- git
-- change telescope layout
-- Detect root dir if possible
-- More config on telescope/
--
-- Highlight and search for more, highlight multiple pattern same time don’t lose highlight when quit search mode
--


-- init
vim.loader.enable()
-- vim.cmd('syntax off')
-- numbers
vim.opt.number                = true
-- others
vim.opt.termguicolors         = true
vim.opt.updatetime            = 100
vim.opt.cursorline            = true
vim.opt.autowrite             = true
vim.opt.wrap                  = true
vim.opt.mouse                 = nil
vim.opt.keywordprg            = 'man'
vim.opt.scrolloff             = 8
vim.opt.sidescrolloff         = 8
vim.opt.undofile              = true

-- fold
vim.o.foldcolumn              = '1'
vim.o.foldlevel               = 99
vim.o.foldlevelstart          = 99
vim.o.foldenable              = true
vim.o.signcolumn              = 'yes'

-- tabs
vim.opt.shiftround            = true
vim.opt.autoindent            = true
vim.opt.tabstop               = 4
vim.opt.softtabstop           = 4
vim.opt.shiftwidth            = 4
vim.opt.expandtab             = true

vim.g.python_host_skip_check  = 1
vim.g.python_host_prog        = "/usr/bin/python3"
vim.g.python3_host_skip_check = 1
vim.g.python3_host_prog       = "/usr/bin/python3"


vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
-- load core config
require("core.plugins")
require("mason").setup()
-- require("mason-lspconfig").setup {
--   ensure_installed = {"clangd", 'lua_ls'}
-- }
require("nvim_comment").setup()
require("nvim-surround").setup()
require("neodev").setup()
if vim.g.shadowvim == nil and vim.g.vscode == nil then
  -- themes
  -- vim.g.gruvbox_material_background = 'hard'
  vim.g.gruvbox_material_foreground = 'material'
  vim.g.gruvbox_material_transparent_background = 0
  vim.g.gruvbox_material_better_performance = 1
  vim.o.background = 'dark'
  vim.cmd([[colorscheme gruvbox-material]])
  -- require("vscode").load()
  require("config.lsp_config").config()
  require("config.lsp_misc").config()
  require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
      return { 'treesitter', 'indent' }
    end
  })
  require("config.statusline").config()
  require("config.oil").config()
  require("config.terminal").config()
  require("config.treesitter").config()
  require('config.telescope').config()
  require("tailwind-tools").setup({})
  require("ibl").setup({
    indent = {
      char = '▏'
    },
    scope = {
      enabled = true,
      show_exact_scope = true,
    }
  })

  require('gitsigns').setup {
    signs                        = {
      add          = { text = '┃' },
      change       = { text = '┃' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    signs_staged                 = {
      add          = { text = '┃' },
      change       = { text = '┃' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    signs_staged_enable          = true,
    signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir                 = {
      follow_files = true
    },
    auto_attach                  = true,
    attach_to_untracked          = false,
    current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts      = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
      virt_text_priority = 100,
      use_focus = true,
    },
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    sign_priority                = 6,
    update_debounce              = 100,
    status_formatter             = nil,   -- Use default
    max_file_length              = 40000, -- Disable if file is longer than this (in lines)
    preview_config               = {
      -- Options passed to nvim_open_win
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1
    },
  }


  -- require("leetcode").setup({
  --   lang = "c",
  -- })
end
require("core.autocommand")
require("core.keymap")
