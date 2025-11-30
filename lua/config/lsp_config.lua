local M = {}

function M.config()
  local blink = require("blink.cmp")
  local mason_registry = require('mason-registry')

  -- 1. Define global capabilities for all LSP clients
  local capabilities = blink.get_lsp_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }

  -- Apply capabilities to ALL servers by default
  vim.lsp.config('*', {
    capabilities = capabilities,
  })

  -- 2. Define the list of servers to enable
  local servers = {
    'clangd', 'html', 'ts_ls', 'lua_ls', 'zls', 'rust_analyzer',
    'pylsp', 'volar', 'lemminx', 'jsonls', 'verible', 'hdl_checker', 'bashls'
  }

  -- 3. Helper function for Python environment
  local function which_python()
    local f = io.popen('env which python3', 'r') or error("Fail to execute 'env which python'")
    local s = f:read('*a') or error("Fail to read from io.popen result")
    f:close()
    return string.gsub(s, '%s+$', '')
  end

  -- 4. Helper function to resolve Clangd Build Dir (Ported from your logic)
  local function get_clangd_cmd()
    local possible_build_dirs = {
      "build", "cmake-build-debug", "cmake-build-release", "cmake_build", "buildsofcmake",
    }
    local fallback_dir = "build"
    
    -- In Nvim 0.11, we use vim.fs.root for detection
    -- We try to find the root based on your patterns
    local root_patterns = { '.git', '.clangd', 'compile_commands.json' }
    -- Add build dir patterns to root detection
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

  -- 5. Server Specific Configurations
  -- We set the config using vim.lsp.config('name', {cfg}) before enabling them

  -- [clangd]
  vim.lsp.config('clangd', {
    cmd = get_clangd_cmd(),
    root_markers = { '.clangd', 'compile_commands.json', '.git' } -- Native 0.11 root markers
  })

  -- [hdl_checker]
  vim.lsp.config('hdl_checker', {
    filetypes = { 'vhdl' }
  })

  -- [verible]
  vim.lsp.config('verible', {
    filetypes = { "systemverilog", "verilog" },
    -- Dynamically resolve path via mason if possible, otherwise falls back to defaults or use explicit path
    cmd = {
      mason_registry.get_package('verible'):get_install_path() .. '/bin/verible-verilog-ls',
      '--rules_config_search',
      '--rules=-line-length,-no-trailing-spaces,-no-tabs'
    }
  })

  -- [ts_ls] (formerly tsserver)
  local vue_ls_path = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
  vim.lsp.config('ts_ls', {
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = vue_ls_path,
          language = { 'vue' }
        }
      }
    }
  })

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

  -- [volar]
  vim.lsp.config('volar', {
    init_options = {
      vue = { hybridMode = false },
      typescript = { tsdk = '' },
      languageFeatures = {
        implementation = true,
        references = true,
        definition = true,
        typeDefinition = true,
        callHierarchy = true,
        hover = true,
        rename = true,
        renameFileRefactoring = true,
        signatureHelp = true,
        codeAction = true,
        workspaceSymbol = true,
        completion = {
          defaultTagNameCase = 'both',
          defaultAttrNameCase = 'kebabCase',
          getDocumentNameCasesRequest = false,
          getDocumentSelectionRequest = false,
        },
      }
    }
  })

  -- 6. Enable all servers
  -- This replaces the loop iterating over setup()
  vim.lsp.enable(servers)

  -- 7. Keymaps and Buffer Attachment (LspAttach)
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
    callback = function(ev)
      -- Enable completion triggered by <c-x><c-o>
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
