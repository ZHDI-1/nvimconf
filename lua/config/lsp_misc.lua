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
      preset        = 'none',

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
      ['<C-p>']     = { 'show', 'select_prev', 'fallback' },
      ['<C-n>']     = { 'show', 'select_next', 'fallback' },

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
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },

      -- Configure specific provider options (like keyword length)
      -- this may usefull later
      -- min_keyword_length = function(ctx)
      -- If I pressed <C-Space> (manual), show immediately (limit 0)
  --     if ctx.trigger.initial_kind == 'manual' then
  --       return 0
  --     end
  --     -- Otherwise, enforce the limit (e.g., 3 chars)
  --     return 3
  --   end
  -- }
      providers = {
        lsp = {
          min_keyword_length = 0, -- Matches your old completion.keyword_length = 2
        },
        buffer = {
          min_keyword_length = 0,
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      },
    },

    completion = {
      keyword = { range = 'full' },

      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      list = { selection = { preselect = true, auto_insert = true } },
      trigger = {
        -- When true, will prefetch the completion items when entering insert mode
        prefetch_on_insert = true,

        -- When false, will not show the completion window automatically when in a snippet
        show_in_snippet = true,

        -- When true, will show completion window after backspacing
        show_on_backspace = true,

        -- When true, will show completion window after backspacing into a keyword
        show_on_backspace_in_keyword = true,

        -- When true, will show the completion window after accepting a completion and then backspacing into a keyword
        show_on_backspace_after_accept = true,

        -- When true, will show the completion window after entering insert mode and backspacing into keyword
        show_on_backspace_after_insert_enter = true,

        -- When true, will show the completion window after typing any of alphanumerics, `-` or `_`
        show_on_keyword = true,

        -- When true, will show the completion window after typing a trigger character
        show_on_trigger_character = true,

        -- When true, will show the completion window after entering insert mode
        show_on_insert = false,

        -- LSPs can indicate when to show the completion window via trigger characters
        -- however, some LSPs (i.e. tsserver) return characters that would essentially
        -- always show the window. We block these by default.
        show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
        -- You can also block per filetype with a function:
        -- show_on_blocked_trigger_characters = function(ctx)
        --   if vim.bo.filetype == 'markdown' then return { ' ', '\n', '\t', '.', '/', '(', '[' } end
        --   return { ' ', '\n', '\t' }
        -- end,

        -- When both this and show_on_trigger_character are true, will show the completion window
        -- when the cursor comes after a trigger character after accepting an item
        show_on_accept_on_trigger_character = true,

        -- When both this and show_on_trigger_character are true, will show the completion window
        -- when the cursor comes after a trigger character when entering insert mode
        show_on_insert_on_trigger_character = true,

        -- List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger
        -- the completion window when the cursor comes after a trigger character when
        -- entering insert mode/accepting an item
        show_on_x_blocked_trigger_characters = { "'", '"', '(' },
        -- or a function, similar to show_on_blocked_trigger_character
      },
    },

    -- Fuzzy matcher settings
    fuzzy = { implementation = "prefer_rust_with_warning" }
  })

  -- trouble setup
  require("trouble").setup {}
end

return M
