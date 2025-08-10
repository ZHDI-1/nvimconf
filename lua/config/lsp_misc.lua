local M = {}
-- luasnip setup
function M.config()
  local luasnip = require 'luasnip'

  local cmp = require("blink.cmp")
  cmp.setup({
    keymap = { preset = 'default' },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  })

  -- nvim-cmp setup
  -- local cmp = require 'cmp'

  -- cmp.setup({
  --   snippet = {
  --     expand = function(args)
  --       luasnip.lsp_expand(args.body)
  --     end,
  --
  --   },
  --   completion = {
  --     keyword_length = 2,
  --   },
  --   performance = {
  --     max_view_entries = 100,
  --     async_budget = 1,
  --     debounce = 50,
  --     confirm_resolve_timeout = 65,
  --     throttle = 30,
  --     fetching_timeout = 200,
  --   },
  --   mapping = cmp.mapping.preset.insert({
  --     ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
  --     ['<C-d>'] = cmp.mapping.scroll_docs(4),  -- Down
  --     -- C-b (back) C-f (forward) for snippet placeholder navigation.
  --     ['<C-Space>'] = cmp.mapping.complete(),
  --     ['<C-y>'] = cmp.mapping.confirm {
  --       behavior = cmp.ConfirmBehavior.Replace,
  --       select = true,
  --     },
  --     ['CR'] = cmp.config.disable,
  --     ["<Tab>"] = cmp.mapping(function(fallback)
  --       if luasnip.locally_jumpable(1) then
  --         luasnip.jump(1)
  --       else
  --         fallback()
  --       end
  --     end, { "i", "s" }),
  --     ["<S-Tab>"] = cmp.mapping(function(fallback)
  --       if luasnip.locally_jumpable(-1) then
  --         luasnip.jump(-1)
  --       else
  --         fallback()
  --       end
  --     end, { "i", "s" }),
  --
  --   }),
  --   sources = {
  --     { name = 'nvim_lsp' },
  --     { name = 'luasnip' },
  --     { name = 'buffer' },
  --   },
  -- })

  -- troube
  require("trouble").setup {
  }

  -- ufo-fold
end

return M
