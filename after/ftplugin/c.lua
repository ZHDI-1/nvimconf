require("config.c.common").setup()

if require("core.project").is_kernel_tree(0) then
	require("config.c.kernel").setup()
end
