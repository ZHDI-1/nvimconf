local M = {}

local function buf_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(name)
end

local function has_root_file(bufnr, names)
  return vim.fs.find(names, {
    upward = true,
    path = buf_dir(bufnr),
  })[1] ~= nil
end

local function c_formatters(bufnr)
  if has_root_file(bufnr, { ".clang-format", "_clang-format" }) then
    return { "clang_format", lsp_format = "never" }
  end

  return { lsp_format = "never" }
end

local function python_formatters(bufnr)
  local conform = require("conform")

  if conform.get_formatter_info("ruff_format", bufnr).available then
    return {
      "ruff_fix",
      "ruff_organize_imports",
      "ruff_format",
      lsp_format = "never",
    }
  end

  if conform.get_formatter_info("black", bufnr).available then
    local formatters = { lsp_format = "never" }

    if conform.get_formatter_info("isort", bufnr).available then
      table.insert(formatters, "isort")
    end

    table.insert(formatters, "black")
    return formatters
  end

  return { lsp_format = "fallback" }
end

function M.config()
  require("conform").setup({
    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 1500,
    },
    formatters_by_ft = {
      bash = { "shfmt" },
      c = c_formatters,
      cpp = c_formatters,
      css = { "prettierd", "prettier", stop_after_first = true },
      go = { "goimports", "gofmt" },
      html = { "prettierd", "prettier", stop_after_first = true },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
      lua = { "stylua" },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      python = python_formatters,
      rust = { "rustfmt", lsp_format = "fallback" },
      scss = { "prettierd", "prettier", stop_after_first = true },
      sh = { "shfmt" },
      toml = { "taplo" },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      vue = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      zig = { "zigfmt" },
      zsh = { "shfmt" },
    },
    notify_on_error = true,
    notify_no_formatters = true,
  })

  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
end

return M
