local M = {}

function M.config()
  -- nvim-treesitter config
  -- local language_list = { "python", "javascript", "cmake", "css", "devicetree", "dot", "dockerfile", "html", "json",
  --   "kconfig", "latex", "llvm", "luadoc", "make", "ninja", "rust", "zig", "swift", "tmux", "tsx", "tsv", "typescript",
  --   "xml", "yaml", "bash", "c", "cpp", "vim", "lua", "markdown"}
  local language_list = { "python", "bash", "c", "cpp" }

  ---@diagnostic disable-next-line: missing-fields
  require 'nvim-treesitter.configs'.setup {
    -- ensure_installed = "maintained", -- for installing all maintained parsers
    ensure_installed = language_list,
    sync_install = true, -- install synchronously
    ignore_install = {}, -- parsers to not install
    auto_install = true,
    highlight = {
      enable = true,
      disable = function(lang, buf)
        if (lang == 'verilog') then
          return true
        end
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
      additional_vim_regex_highlighting = false, -- disable standard vim highlighting
    },
    indent = {
      enable = true,
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
      [".zshenv"] = "sh"
    }
  }
end

return M
