local M = {}

local uv = vim.uv

M.build_dirs = {
	"build",
	"cmake-build-debug",
	"cmake-build-release",
	"cmake_build",
	"buildsofcmake",
}

local function exists(path)
	return path and uv.fs_stat(path) ~= nil
end

local function buf_path(bufnr)
	bufnr = bufnr or 0
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return vim.fn.getcwd()
	end
	return name
end

function M.root(bufnr, markers)
	local path = buf_path(bufnr)
	local stat = uv.fs_stat(path)
	local start = stat and stat.type == "directory" and path or vim.fs.dirname(path)
	return vim.fs.root(start, markers)
end

function M.find_project_root(bufnr)
	return M.root(bufnr, {
		"compile_commands.json",
		"Cargo.toml",
		"build.zig",
		"package.json",
		"pyproject.toml",
		"setup.py",
		".git",
	}) or vim.fn.getcwd()
end

function M.clangd_root(bufnr)
	local markers = { "compile_commands.json", ".clangd", ".git" }
	for _, dir in ipairs(M.build_dirs) do
		table.insert(markers, dir .. "/compile_commands.json")
	end
	return M.root(bufnr, markers) or M.find_project_root(bufnr)
end

function M.clangd_compile_commands_dir(root)
	if not root then
		return nil
	end

	if exists(vim.fs.joinpath(root, "compile_commands.json")) then
		return root
	end

	for _, dir in ipairs(M.build_dirs) do
		local candidate = vim.fs.joinpath(root, dir, "compile_commands.json")
		if exists(candidate) then
			return vim.fs.joinpath(root, dir)
		end
	end

	return nil
end

function M.find_python(bufnr)
	local root = M.root(bufnr, {
		"pyproject.toml",
		"poetry.lock",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git",
	})

	return M.find_python_from_root(root)
end

function M.find_python_from_root(root)
	if root then
		local candidates = {
			vim.fs.joinpath(root, ".venv", "bin", "python"),
			vim.fs.joinpath(root, "venv", "bin", "python"),
		}

		for _, path in ipairs(candidates) do
			if exists(path) then
				return path
			end
		end
	end

	return "python3"
end

function M.is_kernel_tree(bufnr)
	local root = M.root(bufnr, { "Kconfig", "Makefile", ".git" })
	if not root then
		return false
	end

	return exists(vim.fs.joinpath(root, "Kconfig"))
		and exists(vim.fs.joinpath(root, "Makefile"))
		and exists(vim.fs.joinpath(root, "include", "linux"))
end

return M
