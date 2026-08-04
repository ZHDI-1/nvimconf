local M = {}

local log_root = vim.fs.joinpath(vim.fn.stdpath("state"), "lsp-logs")
local session_id = ("%s-%d"):format(os.date("%Y%m%d-%H%M%S"), vim.fn.getpid())
local session_log = vim.fs.joinpath(log_root, "nvim", session_id .. ".log")
local server_files = {}
local configured = false
local server_aliases = {
	["typescript-language-server"] = "ts_ls",
	["vscode-html-language-server"] = "html",
	["vscode-json-language-server"] = "jsonls",
}

local function safe_name(server)
	local name = vim.fs.basename(server):gsub("%.exe$", "")
	return name:gsub("[^%w._-]", "_")
end

local function server_name(server)
	local executable = safe_name(server)
	return server_aliases[executable] or executable
end

function M.server_log_path(server)
	return vim.fs.joinpath(log_root, server_name(server), session_id .. ".log")
end

local function write_server(server, text)
	local name = server_name(server)
	local file = server_files[name]

	if not file then
		local dir = vim.fs.joinpath(log_root, name)
		if not vim.uv.fs_stat(dir) then
			local ok = vim.uv.fs_mkdir(dir, 493) -- 0755
			if not ok and not vim.uv.fs_stat(dir) then
				return false
			end
		end

		file = io.open(vim.fs.joinpath(dir, session_id .. ".log"), "a")
		if not file then
			return false
		end
		server_files[name] = file
	end

	file:write(text)
	file:flush()
	return true
end

local function format_nvim_log(level, ...)
	local info = debug.getinfo(3, "Sl")
	local parts = {
		("[%s][%s] %s:%s"):format(level, os.date("%F %H:%M:%S"), info.short_src, info.currentline),
	}

	for index = 1, select("#", ...) do
		local value = select(index, ...)
		table.insert(parts, value == nil and "nil" or vim.inspect(value, { newline = " ", indent = "" }))
	end

	return table.concat(parts, "\t") .. "\n"
end

local function format_server_log(level, source, message)
	local text = type(message) == "string" and message or vim.inspect(message, { newline = " ", indent = "" })
	local suffix = vim.endswith(text, "\n") and "" or "\n"
	return ("[%s][%s][%s]\t%s%s"):format(level, os.date("%F %H:%M:%S"), source, text, suffix)
end

local function format_log(level, ...)
	local level_number = vim.lsp.log.levels[level]
	if not level_number or level_number < vim.lsp.log.get_level() then
		return nil
	end

	local args = { ... }
	if
		args[1] == "rpc"
		and type(args[2]) == "string"
		and args[3] == "stderr"
		and type(args[4]) == "string"
		and write_server(args[2], format_server_log("STDERR", "process", args[4]))
	then
		return nil
	end

	local message = format_nvim_log(level, ...)
	local server = type(args[1]) == "string" and args[1]:match("^LSP%[([^%]]+)%]$")
	if server and write_server(server, message) then
		return nil
	end

	return message
end

local function client_name(ctx)
	local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
	return client and client.name or ("id-%s"):format(ctx and ctx.client_id or "unknown")
end

M.handlers = {
	["window/logMessage"] = function(_, params, ctx)
		local levels = {
			[vim.lsp.protocol.MessageType.Error] = "ERROR",
			[vim.lsp.protocol.MessageType.Warning] = "WARN",
			[vim.lsp.protocol.MessageType.Info] = "INFO",
			[vim.lsp.protocol.MessageType.Log] = "INFO",
		}
		local level = levels[params.type] or "DEBUG"
		write_server(client_name(ctx), format_server_log(level, "window/logMessage", params.message))
		return params
	end,
	["$/logTrace"] = function(_, params, ctx)
		local message = params.verbose and ("%s\n%s"):format(params.message, params.verbose) or params.message
		write_server(client_name(ctx), format_server_log("TRACE", "$/logTrace", message))
		return params
	end,
}

function M.setup(servers)
	for _, server in ipairs(servers or {}) do
		local config = vim.lsp.config[server]
		if config and type(config.cmd) == "table" and type(config.cmd[1]) == "string" then
			server_aliases[safe_name(config.cmd[1])] = safe_name(server)
		end
	end

	if configured then
		return
	end
	configured = true

	vim.fn.mkdir(vim.fs.dirname(session_log), "p")
	vim.lsp.log._set_filename(session_log)
	vim.lsp.log.set_format_func(format_log)

	local group = vim.api.nvim_create_augroup("UserLspLogging", { clear = true })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			for _, file in pairs(server_files) do
				file:close()
			end
			server_files = {}
		end,
	})

	vim.api.nvim_create_user_command("LspLogPath", function()
		vim.notify(vim.lsp.log.get_filename())
	end, { desc = "Show this Neovim session's LSP log" })

	vim.api.nvim_create_user_command("LspLogDir", function()
		vim.notify(log_root)
	end, { desc = "Show the directory containing all LSP logs" })
end

return M
