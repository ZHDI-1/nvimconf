local project = require("core.project")

local nproc = math.max(1, #(vim.uv.cpu_info() or { 1 }))

local base_cmd = {
	"clangd",
	"--background-index",
	"--background-index-priority=normal",
	"--limit-references=1000",
	"--limit-results=1000",
	"--rename-file-limit=500",
	"-j=" .. nproc,
	"--clang-tidy",
	"--header-insertion=never",
	"--pch-storage=memory",
}

return {
	cmd = function(dispatchers, config)
		local cmd = vim.deepcopy(base_cmd)
		local compile_commands_dir = project.clangd_compile_commands_dir(config.root_dir)

		if compile_commands_dir then
			table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
		end

		return vim.lsp.rpc.start(cmd, dispatchers, {
			cwd = config.cmd_cwd or config.root_dir,
			env = config.cmd_env,
			detached = config.detached,
		})
	end,
	filetypes = { "c", "cpp", "objc", "objcpp" },
	root_dir = function(bufnr, on_dir)
		on_dir(project.clangd_root(bufnr))
	end,
}
