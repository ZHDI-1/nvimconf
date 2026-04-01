local M = {}

function M.config()
  local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter"
  vim.opt.runtimepath:append(parser_install_dir)

  local language_list = {
    "bash",
    "c",
    "cpp",
    "json",
    "lua",
    "markdown",
    "python",
    "query",
    "rust",
    "toml",
    "vim",
    "vimdoc",
    "zig",
  }

  ---@diagnostic disable-next-line: missing-fields
  require 'nvim-treesitter.configs'.setup {
    -- ensure_installed = "maintained", -- for installing all maintained parsers
    ensure_installed = language_list,
    parser_install_dir = parser_install_dir,
    sync_install = false,
    ignore_install = {}, -- parsers to not install
    auto_install = false,
    highlight = {
      enable = true,
      disable = function(lang, buf)
        if (lang == 'verilog') then
          return true
        end
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
      additional_vim_regex_highlighting = false, -- disable standard vim highlighting
    },
    indent = {
      enable = true,
      disable = { "c", "cpp" },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = false,
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      }
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,

        keymaps = {
          ['af'] = "@function.outer",
          ['if'] = "@function.inner",
          ['ac'] = "@class.outer",
          ['ic'] = "@class.inner",
          ['aa'] = "@assignment.outer",
          ['ia'] = "@assignment.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = "@parameter.inner",
        },
        swap_previous = {
          ['<leader>A'] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
          ["]o"] = "@loop.*",
          ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
          ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
        goto_next = {
          ["]d"] = "@conditional.outer",
        },
        goto_previous = {
          ["[d"] = "@conditional.outer",
        }
      },
      lsp_interop = {
        enable = true,
        border = 'none',
        floating_preview_opts = {},
        peek_definition_code = {
          ["<leader>df"] = "@function.outer",
          ["<leader>dF"] = "@class.outer",
        },
      }
    }
  }
  vim.filetype.add {
    extension = {
      zsh = "sh",
      sh  = "sh",
    },
    filename  = {
      [".zshrc"] = "sh",
      [".zshenv"] = "sh",
      [".bashrc"] = "sh",
      [".bash_profile"] = "sh",
    }
  }

  require'treesitter-context'.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  multiwindow = false, -- Enable multiwindow support.
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'topline',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
end

return M
