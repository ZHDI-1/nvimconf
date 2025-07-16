local M = {}
-- luasnip setup
function M.config()
  local luasnip = require 'luasnip'

  -- nvim-cmp setup
  local cmp = require 'cmp'
  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,

    },
    completion = {
      keyword_length = 3,
    },
    performance = {
      max_view_entries = 100,
      async_budget = 1,
      debounce = 50,
      confirm_resolve_timeout = 65,
      throttle = 30,
      fetching_timeout = 200,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
      ['<C-d>'] = cmp.mapping.scroll_docs(4),  -- Down
      -- C-b (back) C-f (forward) for snippet placeholder navigation.
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-y>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['CR'] = cmp.config.disable,
      ["<Tab>"] = cmp.mapping(function(fallback)
        if luasnip.locally_jumpable(1) then
          luasnip.jump(1)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),

    }),
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'luasnip' },
    },
  }
  -- troube
  require("trouble").setup {
  }

  -- ufo-fold
  
end

return M
