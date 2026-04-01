local M = {}

function M.mason_bin(binary_name)
  local bin_path = vim.fn.stdpath("data") .. "/mason/bin/" .. binary_name
  if vim.fn.filereadable(bin_path) == 1 then
    return bin_path
  end
  return binary_name
end

function M.mason_package_path(package_name)
  local install_root = vim.fn.stdpath("data") .. "/mason/packages/" .. package_name
  if vim.fn.isdirectory(install_root) == 1 then
    return install_root
  end
  return nil
end

return M
