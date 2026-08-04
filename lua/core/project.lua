local M = {}

local uv = vim.uv

M.build_dirs = {
	"build",
	"clangd-build",
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

local function realpath(path)
	if not path or path == "" then
		return nil
	end

	return uv.fs_realpath(path) or vim.fs.normalize(path)
end

local function path_is_below(path, root)
	path = realpath(path)
	root = realpath(root)

	if not path or not root then
		return false
	end

	return path == root or path:sub(1, #root + 1) == root .. "/"
end

local function start_dir(path)
	path = realpath(path)
	if not path then
		return nil
	end

	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory" and path or vim.fs.dirname(path)
end

local workspace_root_cache = nil
local workspace_targets_cache = nil

local function discover_logical_workspace(path)
	-- NVIM_WORKSPACE is the strongest signal. PWD is checked before
	-- getcwd() because the shell may preserve a logical symlink path in PWD.
	local candidates = {
		start_dir(path),
		vim.env.NVIM_WORKSPACE,
		vim.env.PWD,
		vim.fn.getcwd(),
	}

	if workspace_root_cache and exists(vim.fs.joinpath(workspace_root_cache, ".nvim-workspace")) then
		table.insert(candidates, 2, workspace_root_cache)
	end

	for _, start in ipairs(candidates) do
		if start and start ~= "" then
			local root = vim.fs.root(start, ".nvim-workspace")
			if root then
				if root ~= workspace_root_cache then
					workspace_targets_cache = nil
				end
				workspace_root_cache = root
				return root
			end
		end
	end

	return nil
end

local function workspace_targets(workspace)
	if workspace_targets_cache then
		return workspace_targets_cache
	end

	local targets = {}

	-- Record the workspace itself.
	table.insert(targets, realpath(workspace))

	-- Record the real destinations of immediate directory symlinks such as:
	--   workspace/linux
	--   workspace/ceph-client
	for name, kind in vim.fs.dir(workspace) do
		if kind == "link" or kind == "directory" then
			local child = vim.fs.joinpath(workspace, name)
			local target = realpath(child)

			if target then
				table.insert(targets, target)
			end
		end
	end

	workspace_targets_cache = targets
	return targets
end

function M.workspace_root_from_path(path)
	local workspace = discover_logical_workspace(path)
	if not workspace then
		return nil
	end

	for _, target in ipairs(workspace_targets(workspace)) do
		if path_is_below(path, target) then
			return workspace
		end
	end

	return nil
end

function M.workspace_root(bufnr)
	return M.workspace_root_from_path(buf_path(bufnr))
end

function M.root_from_path(path, markers)
	local start = start_dir(path)
	return start and vim.fs.root(start, markers) or nil
end

function M.root(bufnr, markers)
	return M.root_from_path(buf_path(bufnr), markers)
end

function M.find_project_root_from_path(path)
	return M.workspace_root_from_path(path)
		or M.root_from_path(path, {
			".nvim-workspace",
			"compile_commands.json",
			"Cargo.toml",
			"build.zig",
			"package.json",
			"pyproject.toml",
			"setup.py",
			".git",
		})
		or vim.fn.getcwd()
end

function M.find_project_root(bufnr)
	return M.find_project_root_from_path(buf_path(bufnr))
end

function M.search_root(bufnr)
	return M.workspace_root(bufnr) or M.find_project_root(bufnr)
end

function M.clangd_root_from_path(path)
	local workspace = M.workspace_root_from_path(path)

	if workspace and exists(vim.fs.joinpath(workspace, "compile_commands.json")) then
		return workspace
	end

	local markers = {
		"compile_commands.json",
		".clangd",
		".git",
	}

	for _, dir in ipairs(M.build_dirs) do
		table.insert(markers, dir .. "/compile_commands.json")
	end

	return M.root_from_path(path, markers) or M.find_project_root_from_path(path)
end

function M.clangd_root(bufnr)
	return M.clangd_root_from_path(buf_path(bufnr))
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
