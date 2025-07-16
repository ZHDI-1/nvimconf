local M = {}
function M.config()
  -- lualine config
  require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'auto', -- based on current vim colorscheme
      -- not a big fan of fancy triangle separators
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
        tabline = { 'man' }
      },
      always_divide_middle = false,
    },
    sections = {
      -- left
      lualine_a = { 'mode' },
      lualine_b = { 'filename', 'diff', {
        'diagnostics',
        sources = { 'nvim_lsp' },
        colored = true
      }
      },
      lualine_c = {},
      -- right
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_z = { 'searchcount', 'location' }
    },
    inactive_sections = {
      lualine_a = { 'filename' },
      lualine_b = {},
      lualine_c = {},
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {}
    },
    extensions = {}
  }

  local theme = {
  fill = 'TabLineFill',
  -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
  head = 'TabLine',
  current_tab = 'TabLineSel',
  tab = 'TabLine',
  win = 'TabLine',
  tail = 'TabLine',
}
require('tabby').setup({
--   line = function(line)
--     return {
--       {
--         { '  ', hl = theme.head },
--         line.sep('', theme.head, theme.fill),
--       },
--       line.tabs().foreach(function(tab)
--         local hl = tab.is_current() and theme.current_tab or theme.tab
--         return {
--           line.sep('', hl, theme.fill),
--           tab.is_current() and '' or '󰆣',
--           tab.number(),
--           tab.name(),
--           tab.close_btn(''),
--           line.sep('', hl, theme.fill),
--           hl = hl,
--           margin = ' ',
--         }
--       end),
--       line.spacer(),
--       line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
--         return {
--           line.sep('', theme.win, theme.fill),
--           win.is_current() and '' or '',
--           win.buf_name(),
--           line.sep('', theme.win, theme.fill),
--           hl = theme.win,
--           margin = ' ',
--         }
--       end),
--       {
--         line.sep('', theme.tail, theme.fill),
--         { '  ', hl = theme.tail },
--       },
--       hl = theme.fill,
--     }
--   end,
--   -- option = {}, -- setup modules' option,
})
end

return M
