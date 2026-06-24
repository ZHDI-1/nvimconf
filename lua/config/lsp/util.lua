local M = {}

local npm_root

function M.executable(binary_name)
	local bin_path = vim.fn.exepath(binary_name)
	if bin_path ~= "" then
		return bin_path
	end

	return binary_name
end

local function npm_global_root()
	if npm_root ~= nil then
		return npm_root or nil
	end

	local npm = vim.fn.exepath("npm")
	if npm == "" then
		npm_root = false
		return nil
	end

	local result = vim.system({ npm, "root", "-g" }, { text = true }):wait()
	if result.code ~= 0 then
		npm_root = false
		return nil
	end

	local root = vim.trim(result.stdout or "")
	npm_root = root ~= "" and root or false
	return npm_root or nil
end

function M.npm_global_package_path(package_name)
	local root = npm_global_root()
	if not root then
		return nil
	end

	local package_path = vim.fs.joinpath(root, package_name)
	if vim.fn.isdirectory(package_path) == 1 then
		return package_path
	end
	return nil
end

return M
