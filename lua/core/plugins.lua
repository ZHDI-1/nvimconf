-- plugin prework
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()
-- plugin work
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use "dstein64/vim-startuptime"
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"

  -- language
  use 'neovim/nvim-lspconfig'
  use 'L3MON4D3/LuaSnip'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'saadparwaiz1/cmp_luasnip'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use {
    'luckasRanarison/tailwind-tools.nvim',
    run = ':UpdateRemotePlugins'
  }
  use {
    'nvim-flutter/flutter-tools.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
        'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = function ()
      require("flutter-tools").setup {}
    end
  }


  -- use { 'nvim-telescope/telescope-fzf-native.nvim',
  --   run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
  --
  -- use {
  --   'nvim-telescope/telescope.nvim', tag = '0.1.7',
  --   requires = { { 'nvim-lua/plenary.nvim' } }
  -- }
  -- use 'nvim-telescope/telescope-file-browser.nvim'
  use {
    'folke/trouble.nvim',
    requires = 'nvim-tree/nvim-web-devicons',
  }
  use {
    "ibhagwan/fzf-lua",
    requires = 'nvim-tree/nvim-web-devicons'
  }

  -- status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = 'nvim-tree/nvim-web-devicons'
  }

  use 'nanozuki/tabby.nvim'
  -- more misc things
  use 'akinsho/toggleterm.nvim'
  use 'lukas-reineke/indent-blankline.nvim'


  -- theme
  use 'sainnhe/gruvbox-material'
  use 'Mofiqul/vscode.nvim'
  -- might add: git-messager gitsigns
  -- lua dev pulgin
  use 'folke/neodev.nvim'
  -- all setup in miscedit.lua
  use 'terrortylor/nvim-comment'
  use 'kylechui/nvim-surround'
  use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

  use {
    "kawre/leetcode.nvim",
    run = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    requires = {
      "ibhagwan/fzf-lua",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    }
  }
  use({
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        git = {
          -- Return true to automatically git add/mv/rm files
          add = function(path)
            return false
          end,
          mv = function(src_path, dest_path)
            return true
          end,
          rm = function(path)
            return true
          end,
        },
        view_options = {
          show_hidden = true,
        },
      })
    end,
  })
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- candidates
-- hardtime.nvim
-- navigator: leap.nvim hop.nvim easymotion flash.nvim
--
