#!/usr/bin/env -S nvim --headless -l

local arguments = {}
for index = 1, #arg do
	arguments[index] = arg[index]
end

local status = require("core.clangd_index").cli(arguments)
if status ~= 0 then
	os.exit(status)
end
