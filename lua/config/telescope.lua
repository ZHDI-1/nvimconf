local M = {}
function M.config()
  local actions = require("fzf-lua").actions
  require("fzf-lua").setup {
    winopts = {
      height = 0.85,       -- window height
      width  = 1,       -- window width
      row    = 1,          -- window row position (0=top, 1=bottom)
      col    = 0,          -- window col position (0=left, 1=right)
      preview = {
        horizontal = "right:50%"
      }
    },
    keymap = {
      builtin = {
        ["<M-Esc>"] = "hide",         -- hide fzf-lua, `:FzfLua resume` to continue
        ["<F1>"]    = "toggle-help",
        ["<F2>"]    = "toggle-fullscreen",
        -- Only valid with the 'builtin' previewer
        ["<F3>"]    = "toggle-preview-wrap",
        ["<F4>"]    = "toggle-preview",
        -- Rotate preview clockwise/counter-clockwise
        ["<F5>"]    = "toggle-preview-ccw",
        ["<F6>"]    = "toggle-preview-cw",
        -- `ts-ctx` binds require `nvim-treesitter-context`
        ["<F7>"]    = "toggle-preview-ts-ctx",
        ["<F8>"]    = "preview-ts-ctx-dec",
        ["<F9>"]    = "preview-ts-ctx-inc",
        ["<C-r>"]   = "preview-reset",
        ["<C-d>"]   = "preview-page-down",
        ["<C-u>"]   = "preview-page-up",
        ["<C-j>"]   = "preview-down",
        ["<C-k>"]   = "preview-up",
      },
      fzf = {
        -- fzf '--bind=' options
        -- true,        -- uncomment to inherit all the below in your custom config
        ["ctrl-z"] = "abort",
        ["ctrl-f"] = "half-page-down",
        ["ctrl-b"] = "half-page-up",
        ["ctrl-a"] = "beginning-of-line",
        ["ctrl-e"] = "end-of-line",
        ["alt-a"]  = "toggle-all",
        ["alt-g"]  = "first",
        ["alt-G"]  = "last",
        -- Only valid with fzf previewers (bat/cat/git/etc)
        ["f3"]     = "toggle-preview-wrap",
        ["f4"]     = "toggle-preview",
      },
    },
    files = {
      cwd_header = true
    },
    buffers = {
      actions = {
        ["ctrl-w"] = { fn = actions.buf_del, reload = true },
      }
    },
    marks = {
        actions = {
          ['ctrl-w'] = {
            fn = actions.mark_del,
            reload = true
          }
        },
      },
  }
end

return M
