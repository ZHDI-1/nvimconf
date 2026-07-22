local util = require("config.lsp.util")

local vue_pkg_path = util.npm_global_package_path("@vue/language-server")
local ts_plugins = {}

if vue_pkg_path then
	table.insert(ts_plugins, {
		name = "@vue/typescript-plugin",
		location = vue_pkg_path,
		language = { "vue" },
	})
end

return {
	init_options = {
		plugins = ts_plugins,
	},
}
