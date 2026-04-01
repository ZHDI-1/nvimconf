local M = {}

local function current_file_dir(bufnr)
  bufnr = bufnr or 0

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return vim.fn.getcwd()
  end

  local stat = vim.uv.fs_stat(name)
  if not stat then
    return vim.fn.getcwd()
  end

  if stat.type == "directory" then
    return name
  end

  return vim.fs.dirname(name)
end

function M.files_from_current_dir(bufnr)
  require("fzf-lua").files({
    cwd = current_file_dir(bufnr),
  })
end

function M.live_grep_from_current_dir(bufnr)
  require("fzf-lua").live_grep({
    cwd = current_file_dir(bufnr),
  })
end

return M
