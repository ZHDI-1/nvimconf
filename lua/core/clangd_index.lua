local M = {}

local project = require("core.project")
local uv = vim.uv
local active = nil
local configured = false

local help = [[
Usage:
  clangd-background-index [options] [PROJECT]
  :ClangdBackgroundIndex [options] [PROJECT]

Populate or refresh clangd's persistent background index without opening files
in an editor. PROJECT defaults to the current buffer/project or working
directory.

Options:
  --compile-commands-dir DIR  Directory containing compile_commands.json
  --file FILE                 Source file used to trigger project discovery
  --clangd PATH               clangd executable (default: clangd)
  -j N                        Background indexing workers (default: CPU count)
  --priority LEVEL            background, low, or normal (default: normal)
  --timeout SECONDS           Overall deadline; zero means unlimited
  --verbose-clangd            Ask clangd for verbose rather than info logging
  -h, --help                  Show this help
]]

local function exists(path)
	return path and uv.fs_stat(path) ~= nil
end

local function absolute(path, base)
	if not path or path == "" then
		return nil
	end
	if path:sub(1, 1) ~= "/" then
		path = vim.fs.joinpath(base or vim.fn.getcwd(), path)
	end
	return uv.fs_realpath(path) or vim.fs.normalize(path)
end

local function read_file(path)
	local file, error_message = io.open(path, "rb")
	if not file then
		return nil, error_message
	end
	local contents = file:read("*a")
	file:close()
	return contents
end

local function count_shards(cache_dir)
	local handle = uv.fs_scandir(cache_dir)
	if not handle then
		return 0
	end

	local count = 0
	while true do
		local name, kind = uv.fs_scandir_next(handle)
		if not name then
			break
		end
		if kind == "file" and name:sub(-4) == ".idx" then
			count = count + 1
		end
	end
	return count
end

local function current_path()
	local name = vim.api.nvim_buf_get_name(0)
	return name ~= "" and name or vim.fn.getcwd()
end

local function source_from_database(database, requested)
	if requested then
		local source = absolute(requested, vim.fn.getcwd())
		if not source or not exists(source) then
			return nil, "trigger file does not exist: " .. tostring(source or requested)
		end
		return source
	end

	local contents, read_error = read_file(database)
	if not contents then
		return nil, ("cannot read %s: %s"):format(database, read_error)
	end

	local ok, commands = pcall(vim.json.decode, contents)
	if not ok or type(commands) ~= "table" then
		return nil, "invalid compilation database: " .. database
	end

	local suffixes = {
		[".c"] = true,
		[".cc"] = true,
		[".cpp"] = true,
		[".cxx"] = true,
		[".m"] = true,
		[".mm"] = true,
	}
	for _, command in ipairs(commands) do
		if type(command) == "table" and type(command.file) == "string" then
			local source = absolute(command.file, command.directory)
			local suffix = source and source:match("(%.[^./]+)$")
			if source and suffixes[suffix and suffix:lower()] and exists(source) then
				return source
			end
		end
	end

	return nil, "no existing C/C++ source file found in " .. database
end

local function language_id(source)
	local suffix = source:match("(%.[^./]+)$")
	suffix = suffix and suffix:lower() or ""
	if suffix == ".c" then
		return "c"
	elseif suffix == ".m" then
		return "objective-c"
	elseif suffix == ".mm" then
		return "objective-cpp"
	end
	return "cpp"
end

local function analyze_log(path, offset)
	local result = {
		failures = {},
		indexed = 0,
	}
	local file = io.open(path, "rb")
	if not file then
		return result
	end

	file:seek("set", offset or 0)
	local contents = file:read("*a")
	file:close()

	local seen = {}
	for failed in contents:gmatch("Failed to compile ([^,\n]+)") do
		if not seen[failed] then
			seen[failed] = true
			table.insert(result.failures, failed)
		end
	end
	for _ in contents:gmatch("%] Indexed [^\n]+") do
		result.indexed = result.indexed + 1
	end
	table.sort(result.failures)
	return result
end

local function resolve(options)
	local start = absolute(options.path or current_path(), vim.fn.getcwd())
	if not start then
		return nil, "cannot resolve the project start path"
	end

	local root = project.clangd_root_from_path(start)
	local commands_dir = options.compile_commands_dir and absolute(options.compile_commands_dir, vim.fn.getcwd())
		or project.clangd_compile_commands_dir(root)

	if not commands_dir then
		local database_root = project.root_from_path(start, "compile_commands.json")
		commands_dir = project.clangd_compile_commands_dir(database_root)
	end

	local identity = project.find_project_root_from_path(start)
	if not commands_dir then
		return nil,
			(
				"project detected at %s, but no compile_commands.json was found "
				.. "(markers: .git, compile_commands.json, .nvim-workspace)"
			):format(identity)
	end

	local database = vim.fs.joinpath(commands_dir, "compile_commands.json")
	if not exists(database) then
		return nil, "compilation database does not exist: " .. database
	end

	local source, source_error = source_from_database(database, options.file)
	if not source then
		return nil, source_error
	end

	return {
		root = root or identity,
		identity = identity,
		commands_dir = commands_dir,
		database = database,
		source = source,
		cache_dir = vim.fs.joinpath(commands_dir, ".cache", "clangd", "index"),
	}
end

local function parse_number(value, option)
	local number = tonumber(value)
	if not number or number < 0 then
		return nil, ("%s requires a non-negative number"):format(option)
	end
	return number
end

local function parse_args(arguments)
	local options = {
		clangd = "clangd",
		jobs = math.max(1, #(uv.cpu_info() or { 1 })),
		priority = "normal",
		timeout = 0,
	}
	local positional = {}
	local index = 1

	local function take(option)
		index = index + 1
		local value = arguments[index]
		if not value then
			return nil, option .. " requires a value"
		end
		return value
	end

	while index <= #arguments do
		local argument = arguments[index]
		local name, inline = argument:match("^(%-%-[^=]+)=(.*)$")
		if argument == "-h" or argument == "--help" then
			options.help = true
		elseif argument == "--verbose-clangd" then
			options.verbose_clangd = true
		elseif argument == "--compile-commands-dir" or name == "--compile-commands-dir" then
			local value, err = inline or take("--compile-commands-dir")
			if not value then
				return nil, err
			end
			options.compile_commands_dir = value
		elseif argument == "--file" or name == "--file" then
			local value, err = inline or take("--file")
			if not value then
				return nil, err
			end
			options.file = value
		elseif argument == "--clangd" or name == "--clangd" then
			local value, err = inline or take("--clangd")
			if not value then
				return nil, err
			end
			options.clangd = value
		elseif argument == "--priority" or name == "--priority" then
			local value, err = inline or take("--priority")
			if not value then
				return nil, err
			end
			if not vim.tbl_contains({ "background", "low", "normal" }, value) then
				return nil, "--priority must be background, low, or normal"
			end
			options.priority = value
		elseif argument == "--timeout" or name == "--timeout" then
			local value, err = inline or take("--timeout")
			if not value then
				return nil, err
			end
			options.timeout, err = parse_number(value, "--timeout")
			if not options.timeout then
				return nil, err
			end
		elseif argument == "-j" then
			local value, err = take("-j")
			if not value then
				return nil, err
			end
			options.jobs, err = parse_number(value, "-j")
			if not options.jobs or options.jobs < 1 then
				return nil, err or "-j must be at least 1"
			end
		elseif argument:match("^%-j%d+$") then
			options.jobs = tonumber(argument:sub(3))
		elseif argument:sub(1, 1) == "-" then
			return nil, "unknown option: " .. argument
		else
			table.insert(positional, argument)
		end
		index = index + 1
	end

	if #positional > 1 then
		return nil, "expected at most one PROJECT path"
	end
	options.path = positional[1]
	return options
end

local function default_report(kind, message)
	local levels = {
		error = vim.log.levels.ERROR,
		warn = vim.log.levels.WARN,
	}
	if kind == "progress" then
		vim.api.nvim_echo({ { message, "Normal" } }, false, {})
	else
		vim.notify(message, levels[kind] or vim.log.levels.INFO, { title = "clangd index" })
	end
end

function M.start(options, callbacks)
	options = options or {}
	callbacks = callbacks or {}
	local report = callbacks.report or default_report

	if active and not active.done then
		return nil, "a clangd background-index run is already active"
	end

	local resolved, resolve_error = resolve(options)
	if not resolved then
		return nil, resolve_error
	end

	local lsp_log = require("config.lsp.log")
	lsp_log.setup()
	local server_log = lsp_log.server_log_path("clangd")
	local log_stat = uv.fs_stat(server_log)
	local log_offset = log_stat and log_stat.size or 0
	local before = count_shards(resolved.cache_dir)
	local command = {
		options.clangd or "clangd",
		"--background-index",
		"--background-index-priority=" .. (options.priority or "normal"),
		"--compile-commands-dir=" .. resolved.commands_dir,
		"-j=" .. (options.jobs or math.max(1, #(uv.cpu_info() or { 1 }))),
		"--enable-config",
		"--log=" .. (options.verbose_clangd and "verbose" or "info"),
	}

	report("info", "project:     " .. resolved.identity)
	report("info", "database:    " .. resolved.database)
	report("info", "trigger:     " .. resolved.source)
	report("info", "index cache: " .. resolved.cache_dir)
	report("info", "existing:    " .. before .. " shards")

	local source_text, source_error = read_file(resolved.source)
	if not source_text then
		return nil, ("cannot read trigger file %s: %s"):format(resolved.source, source_error)
	end

	local state = {
		done = false,
		progress_started = false,
		progress_generation = 0,
		last_progress = nil,
		shutting_down = false,
		error = nil,
		result = nil,
	}
	active = state

	local function complete(ok, error_message, code, signal)
		if state.done then
			return
		end
		state.done = true
		active = nil

		local after = count_shards(resolved.cache_dir)
		local log_result = analyze_log(server_log, log_offset)
		state.result = {
			ok = ok,
			error = error_message,
			code = code,
			signal = signal,
			before = before,
			after = after,
			indexed = log_result.indexed,
			failures = log_result.failures,
			log = server_log,
			project = resolved,
		}

		report("info", ("cache shards: %d -> %d"):format(before, after))
		report("info", "newly parsed: " .. log_result.indexed)
		report(#log_result.failures == 0 and "info" or "warn", "failures:     " .. #log_result.failures)
		for _, failed in ipairs(log_result.failures) do
			report("warn", "  " .. failed)
		end
		report("info", "clangd log:  " .. server_log)
		if error_message then
			report("error", error_message)
		end
		if callbacks.on_done then
			callbacks.on_done(state.result)
		end
	end

	local function terminate(error_message)
		if state.done then
			return
		end
		state.error = state.error or error_message
		if state.rpc and not state.rpc.is_closing() then
			state.rpc.terminate()
		end
		vim.defer_fn(function()
			if not state.done then
				complete(false, state.error or "clangd did not exit", nil, nil)
			end
		end, 5000)
	end

	local function shutdown()
		if state.done or state.shutting_down then
			return
		end
		state.shutting_down = true
		local sent = state.rpc.request("shutdown", nil, function(err)
			if err then
				terminate("clangd shutdown failed: " .. vim.inspect(err))
				return
			end
			state.rpc.notify("exit", nil)
		end)
		if not sent then
			terminate("failed to send clangd shutdown request")
		end
		vim.defer_fn(function()
			if not state.done and state.shutting_down then
				terminate("clangd did not exit after shutdown")
			end
		end, 10000)
	end

	local dispatchers = {
		notification = function(method, params)
			if method ~= "$/progress" or not params or params.token ~= "backgroundIndexProgress" then
				return
			end

			local value = params.value or {}
			if value.kind == "begin" then
				state.progress_started = true
				state.progress_generation = state.progress_generation + 1
				state.last_progress = "indexing: starting"
				report("progress", state.last_progress)
			elseif value.kind == "report" then
				local message = value.message or ""
				local percentage = value.percentage
				local text = percentage and ("indexing: %s (%.0f%%)"):format(message, percentage)
					or ("indexing: " .. message)
				if text ~= state.last_progress then
					state.last_progress = text
					report("progress", text)
				end
			elseif value.kind == "end" then
				state.progress_generation = state.progress_generation + 1
				local generation = state.progress_generation
				state.last_progress = "indexing: complete"
				report("progress", state.last_progress)
				vim.defer_fn(function()
					if not state.done and generation == state.progress_generation then
						shutdown()
					end
				end, 1000)
			end
		end,
		server_request = function(method, params)
			if method == "workspace/configuration" then
				local result = {}
				for index = 1, #((params or {}).items or {}) do
					result[index] = vim.NIL
				end
				return result
			end
			return vim.NIL
		end,
		on_error = function(code, error_message)
			report("error", ("clangd RPC error %s: %s"):format(code, vim.inspect(error_message)))
		end,
		on_exit = function(code, signal)
			vim.schedule(function()
				local ok = code == 0 and state.progress_started and not state.error
				local error_message = state.error
				if not error_message and code ~= 0 then
					error_message = ("clangd exited with status %d (signal %d)"):format(code, signal)
				elseif not error_message and not state.progress_started then
					error_message = "clangd exited before background indexing started"
				end
				complete(ok, error_message, code, signal)
			end)
		end,
	}

	local ok, rpc_or_error = pcall(vim.lsp.rpc.start, command, dispatchers, {
		cwd = resolved.root,
		detached = false,
	})
	if not ok then
		active = nil
		return nil, "failed to start clangd: " .. rpc_or_error
	end
	state.rpc = rpc_or_error

	local initialize_sent = state.rpc.request("initialize", {
		processId = uv.os_getpid(),
		clientInfo = {
			name = "clangd-background-index",
			version = "1",
		},
		rootUri = vim.uri_from_fname(resolved.root),
		workspaceFolders = {
			{
				uri = vim.uri_from_fname(resolved.root),
				name = vim.fs.basename(resolved.root),
			},
		},
		capabilities = {
			window = {
				workDoneProgress = true,
			},
			workspace = {
				configuration = true,
			},
			general = {
				positionEncodings = { "utf-8", "utf-16" },
			},
		},
		trace = "off",
	}, function(err)
		if err then
			terminate("clangd initialize failed: " .. vim.inspect(err))
			return
		end

		state.rpc.notify("initialized", {})
		state.rpc.notify("textDocument/didOpen", {
			textDocument = {
				uri = vim.uri_from_fname(resolved.source),
				languageId = language_id(resolved.source),
				version = 1,
				text = source_text,
			},
		})
	end)
	if not initialize_sent then
		terminate("failed to send clangd initialize request")
	end

	vim.defer_fn(function()
		if not state.done and not state.progress_started then
			terminate("clangd did not report background-index progress within 60 seconds")
		end
	end, 60000)

	if options.timeout and options.timeout > 0 then
		vim.defer_fn(function()
			if not state.done then
				terminate(("clangd indexing exceeded %g seconds"):format(options.timeout))
			end
		end, math.floor(options.timeout * 1000))
	end

	return state
end

function M.cli(arguments)
	local options, parse_error = parse_args(arguments)
	if not options then
		io.stderr:write("error: " .. parse_error .. "\n")
		io.stderr:write(help)
		return 2
	end
	if options.help then
		io.stdout:write(help)
		return 0
	end

	local progress_line = ""
	local tty = uv.guess_handle(1) == "tty"
	local function report(kind, message)
		if tty and kind == "progress" then
			local padding = math.max(0, #progress_line - #message)
			io.stdout:write("\r", message, string.rep(" ", padding))
			io.stdout:flush()
			progress_line = message
			return
		end
		if progress_line ~= "" then
			io.stdout:write("\n")
			progress_line = ""
		end
		local output = kind == "error" and io.stderr or io.stdout
		output:write(message, "\n")
		output:flush()
	end

	local result = nil
	local state, start_error = M.start(options, {
		report = report,
		on_done = function(value)
			result = value
		end,
	})
	if not state then
		report("error", "error: " .. start_error)
		return 2
	end

	while not result do
		vim.wait(1000, function()
			return result ~= nil
		end, 50)
	end
	return result.ok and 0 or 1
end

function M.setup()
	if configured then
		return
	end
	configured = true

	vim.api.nvim_create_user_command("ClangdBackgroundIndex", function(command)
		local options, parse_error = parse_args(command.fargs)
		if not options then
			vim.notify(parse_error, vim.log.levels.ERROR, { title = "clangd index" })
			return
		end
		if options.help then
			vim.notify(help, vim.log.levels.INFO, { title = "clangd index" })
			return
		end

		local _, start_error = M.start(options)
		if start_error then
			vim.notify(start_error, vim.log.levels.ERROR, { title = "clangd index" })
		end
	end, {
		nargs = "*",
		complete = "file",
		desc = "Populate clangd's persistent background index",
	})
end

return M
