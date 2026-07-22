return {
	root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
	settings = {
		Lua = {
			completion = { callSnippet = "Replace" },
			format = {
				enable = true,
				defaultConfig = {
					indent_style = "space",
					auto_collapse_lines = true,
					indent_size = 2,
				},
			},
		},
	},
}
