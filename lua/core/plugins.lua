local M = {}

function M.setup()
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

	if not vim.uv.fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable",
			lazypath,
		})

		if vim.v.shell_error ~= 0 then
			vim.notify("lazy.nvim bootstrap failed; falling back to existing packages", vim.log.levels.WARN)
			return false
		end
	end

	vim.opt.rtp:prepend(lazypath)

	local ok, lazy = pcall(require, "lazy")
	if not ok then
		vim.notify("lazy.nvim is unavailable; falling back to existing packages", vim.log.levels.WARN)
		return false
	end

	lazy.setup("plugins", {
		change_detection = {
			notify = false,
		},
	})

	return true
end

return M
