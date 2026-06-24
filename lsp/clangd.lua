local project = require("core.project")

local nproc = math.max(1, #(vim.uv.cpu_info() or { 1 }))

return {
	cmd = {
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
	},
	filetypes = { "c", "cpp", "objc", "objcpp" },
	root_dir = function(bufnr, on_dir)
		on_dir(project.clangd_root(bufnr))
	end,
	before_init = function(_, config)
		local cmd = vim.deepcopy(config.cmd)
		local compile_commands_dir = project.clangd_compile_commands_dir(config.root_dir)

		if compile_commands_dir then
			table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
		end

		config.cmd = cmd
	end,
}
