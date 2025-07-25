local M = {}

function M.config()
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }
  local lspconfig = require('lspconfig')

  -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
  local servers = {
    'clangd', 'html', 'ts_ls', 'lua_ls', 'zls', 'rust_analyzer',
    'pylsp', 'volar', 'lemminx', 'jsonls', 'verible', 'hdl_checker' }

  local function which_python()
    local f = io.popen('env which python3', 'r') or error("Fail to execute 'env which python'")
    local s = f:read('*a') or error("Fail to read from io.popen result")
    f:close()
    return string.gsub(s, '%s+$', '')
  end



  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup((function()
      local config = {
        capabilities = capabilities,
      }
      local mason_registry = require('mason-registry')
      -- if lsp == 'pyright' then
      --   config.settings = {
      --     python = {
      --       analysis = {
      --         typeCheckingMode = "off",
      --         useLibraryCodeForTypes = true
      --       }
      --     }
      --   }
      -- end
      if lsp == 'clangd' then
        local lsp_util = require('lspconfig.util')
        local possible_build_dirs = {
          "build",
          "cmake-build-debug",
          "cmake-build-release",
          "cmake_build",
          "buildsofcmake",
        }
        -- 2. Define a fallback directory to use if no compile_commands.json is found.
        local fallback_dir = "build"

        -- 3. Generate a list of patterns for finding the project root.
        -- We combine standard project markers with checks for compile_commands.json
        -- in all our possible build directories.
        local root_patterns = {}
        for _, dir in ipairs(possible_build_dirs) do
          table.insert(root_patterns, dir .. '/compile_commands.json')
        end
        table.insert(root_patterns, '.git')
        table.insert(root_patterns, '.clangd')
        table.insert(root_patterns, 'compile_commands.json')

        local root_detector = lsp_util.root_pattern(unpack(root_patterns))

        local find_compile = function()
          local project_root = root_detector()

          if not project_root then
            return
          end

          local compile_commands_dir
          -- first find from root dir of project
          if vim.fn.filereadable(project_root .. '/compile_commands.json') == 1 then
            compile_commands_dir = project_root
          else
            -- If not, search through the list of possible build directories.
            for _, dir_name in ipairs(possible_build_dirs) do
              local check_path = project_root .. '/' .. dir_name
              if vim.fn.filereadable(check_path .. '/compile_commands.json') == 1 then
                compile_commands_dir = dir_name
                break -- Stop searching once we find the first match.
              end
            end
          end

          -- If we didn't find any specific directory, use the configured fallback.
          if not compile_commands_dir then
            compile_commands_dir = project_root .. '/' .. fallback_dir
          end

          return compile_commands_dir
        end

        
        local compile_commands_dir = find_compile() 
        config = {
          root_dir = root_detector,
          cmd = {
            "clangd",
            "--background-index",
            "--background-index-priority=normal",
            "--limit-references=1000",
            "--limit-results=1000",
            "--rename-file-limit=500",
            "-j", "30",
            "--pch-storage=memory",
            "--compile-commands-dir=" .. compile_commands_dir 
          }
        }
      end
      if lsp == 'hdl_checker' then
        config = {
          filetypes = { 'vhdl' }
        }
      end
      if lsp == 'verible' then
        config = {
          filetypes = { "systemverilog", "verilog" },
          cmd = { '/Users/zhdi/.local/share/nvim/mason/bin/verible-verilog-ls', '--rules_config_search', '--rules=-line-length,-no-trailing-spaces,-no-tabs' }
        }
      end
      if lsp == 'tsserver' then
        config.init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = mason_registry.get_package('vue-language-server'):get_install_path() ..
                  '/node_modules/@vue/language-server',
              language = { 'vue' }
            }
          }
        }
      end
      if lsp == 'pylsp' then
        config.settings = {
          pylsp = {
            plugins = {
              black = {
                enabled = true,
                line_length = 80,
                preview = true,
              },
              jedi = {
                environment = which_python()
              },
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
      end
      if lsp == 'lua_ls' then
        config.settings = {
          Lua = {
            completion = {
              callSnippet = "Replace"
            },
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
      end

      if lsp == 'volar' then
        config.init_options = {
          vue = {
            hybridMode = false
          },
          typescript = {
            tsdk = ''
          },
          languageFeatures = {
            implementation = true, -- new in @volar/vue-language-server v0.33
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
      end
      return config
    end)())
    -- on_attach = my_custom_on_attach,
  end

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Buffer local mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
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
      -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<space>gf', function()
        vim.lsp.buf.format { async = true }
      end, opts)
    end,

  })
end

return M
