local M = {}

function M.config()
  local luasnip = require 'luasnip'
  local blink = require("blink.cmp")

  blink.setup({
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- We use 'none' here to strictly match your old nvim-cmp manual bindings
    keymap = {
      preset = 'none',

      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>']     = { 'hide' },
      
      -- Emulate nvim-cmp: <C-y> confirms selection
      ['<C-y>']     = { 'select_and_accept' },

      -- Emulate nvim-cmp: <C-u>/<C-d> for doc scrolling
      ['<C-u>']     = { 'scroll_documentation_up' },
      ['<C-d>']     = { 'scroll_documentation_down' },

      -- Emulate nvim-cmp: Up/Down to navigate list
      ['<Up>']      = { 'select_prev', 'fallback' },
      ['<Down>']    = { 'select_next', 'fallback' },
      ['<C-p>']     = { 'select_prev', 'fallback' },
      ['<C-n>']     = { 'select_next', 'fallback' },

      -- Emulate nvim-cmp: CR (Enter) is disabled for completion (passes through to newline)
      ['<CR>']      = { 'fallback_to_mappings' },

      -- Emulate nvim-cmp: Tab Logic
      -- 1. If snippet active: Jump
      -- 2. Else if menu open: Select Next
      -- 3. Else: Fallback (indent)
      ['<Tab>']     = { 'snippet_forward', 'select_next', 'fallback' },
      ['<S-Tab>']   = { 'snippet_backward', 'select_prev', 'fallback' },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      nerd_font_variant = 'mono'
    },

    signature = { enabled = true },

    -- Integrate LuaSnip
    snippets = { preset = 'luasnip' },

    -- Sources configuration
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      
      -- Configure specific provider options (like keyword length)
      providers = {
        lsp = {
          min_keyword_length = 2, -- Matches your old completion.keyword_length = 2
        },
        buffer = {
          min_keyword_length = 2,
        },
      },
    },

    completion = { 
        keyword = { range = 'prefix' },

        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        list = { selection = { preselect = true, auto_insert = true } },
    },

    -- Fuzzy matcher settings
    fuzzy = { implementation = "prefer_rust_with_warning" }
  })

  -- trouble setup
  require("trouble").setup {}
end

return M
