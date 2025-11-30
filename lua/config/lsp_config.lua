local M = {}

function M.config()
  local blink = require("blink.cmp")
  local mason_registry = require('mason-registry')

  -- 1. Helper: Get Mason Package Path Manually
  -- This avoids the "attempt to call method 'get_install_path'" error by constructing 
  -- the path directly: ~/.local/share/nvim/mason/packages/<name>
  local function get_package_path(package_name)
    local install_root = vim.fn.stdpath("data") .. "/mason/packages/" .. package_name
    if vim.fn.isdirectory(install_root) == 1 then
      return install_root
    end
    return nil
  end

  -- 2. Helper: Get Mason Binary Path
  -- Mason links binaries to ~/.local/share/nvim/mason/bin
  local function get_binary_path(binary_name)
    local bin_path = vim.fn.stdpath("data") .. "/mason/bin/" .. binary_name
    if vim.fn.filereadable(bin_path) == 1 then
      return bin_path
    end
    -- Fallback to system PATH if mason binary doesn't exist
    return binary_name 
  end

  -- 3. Define global capabilities
  local capabilities = blink.get_lsp_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }

  -- Apply capabilities to ALL servers
  vim.lsp.config('*', {
    capabilities = capabilities,
  })

  local servers = {
    'clangd', 'html', 'ts_ls', 'lua_ls', 'zls', 'rust_analyzer',
    'pylsp', 'vue_ls', 'lemminx', 'jsonls', 'verible', 'hdl_checker', 'bashls'
  }

  local function which_python()
    local f = io.popen('env which python3', 'r')
    if not f then return 'python3' end
    local s = f:read('*a')
    f:close()
    if not s then return 'python3' end
    return string.gsub(s, '%s+$', '')
  end

  -- Clangd Command Builder
  local function get_clangd_cmd()
    local possible_build_dirs = {
      "build", "cmake-build-debug", "cmake-build-release", "cmake_build", "buildsofcmake",
    }
    local fallback_dir = "build"
    local root_patterns = { '.git', '.clangd', 'compile_commands.json' }
    for _, dir in ipairs(possible_build_dirs) do
      table.insert(root_patterns, dir .. '/compile_commands.json')
    end

    local cwd = vim.fn.getcwd()
    local project_root = vim.fs.root(cwd, root_patterns) or cwd
    local compile_commands_dir = nil

    if vim.fn.filereadable(project_root .. '/compile_commands.json') == 1 then
      compile_commands_dir = project_root
    else
      for _, dir_name in ipairs(possible_build_dirs) do
        local check_path = project_root .. '/' .. dir_name
        if vim.fn.filereadable(check_path .. '/compile_commands.json') == 1 then
          compile_commands_dir = dir_name
          break
        end
      end
    end

    if not compile_commands_dir then
      compile_commands_dir = project_root .. '/' .. fallback_dir
    end

    return {
      "clangd",
      "--background-index",
      "--background-index-priority=normal",
      "--limit-references=1000",
      "--limit-results=1000",
      "--rename-file-limit=500",
      "-j", "48",
      "--pch-storage=memory",
      "--compile-commands-dir=" .. compile_commands_dir
    }
  end

  -- === Server Configs ===

  -- [clangd]
  vim.lsp.config('clangd', {
    cmd = get_clangd_cmd(),
    root_markers = { '.clangd', 'compile_commands.json', '.git' }
  })

  -- [hdl_checker]
  vim.lsp.config('hdl_checker', {
    filetypes = { 'vhdl' }
  })

  -- [verible]
  vim.lsp.config('verible', {
    filetypes = { "systemverilog", "verilog" },
    cmd = {
      get_binary_path('verible-verilog-ls'), -- Uses manual path check
      '--rules_config_search',
      '--rules=-line-length,-no-trailing-spaces,-no-tabs'
    }
  })

  -- -- [ts_ls]
  -- -- We need the specific location of the Vue language server module
  -- local vue_pkg_path = get_package_path('vue-language-server')
  -- local ts_plugins = {}
  --
  -- if vue_pkg_path then
  --   table.insert(ts_plugins, {
  --     name = "@vue/typescript-plugin",
  --     location = vue_pkg_path .. '/node_modules/@vue/language-server',
  --     language = { 'vue' }
  --   })
  -- end
  --
  -- vim.lsp.config('ts_ls', {
  --   init_options = {
  --     plugins = ts_plugins
  --   }
  -- })

  -- [pylsp]
  vim.lsp.config('pylsp', {
    settings = {
      pylsp = {
        plugins = {
          black = { enabled = true, line_length = 80, preview = true },
          jedi = { environment = which_python() },
          rope_autoimport = {
            enabled = true,
            completions = { enabled = false },
            code_actions = { enabled = true },
          },
          pycodestyle = {
            enabled = true,
            ignore = { 'E501', 'E231' },
            maxLineLength = 80
          }
        }
      }
    }
  })

  -- [lua_ls]
  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        completion = { callSnippet = "Replace" },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = "space",
            auto_collapse_lines = true,
            indent_size = 2
          }
        }
      }
    }
  })

  -- 4. Enable all servers
  vim.lsp.enable(servers)

  -- 5. Attach Keymaps
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
    callback = function(ev)
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
      local opts = { buffer = ev.buf }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
      vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts)
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<space>gf', function()
        vim.lsp.buf.format { async = true }
      end, opts)
    end,
  })
end

return M
