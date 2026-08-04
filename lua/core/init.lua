-- TODO:
-- session manage with au/root dir detect
-- git
-- change telescope layout
-- Detect root dir if possible
-- More config on telescope/
--
-- Highlight and search for more, highlight multiple pattern same time don’t lose highlight when quit search mode
--

-- init
vim.g.mapleader = " "
vim.loader.enable()
-- vim.cmd('syntax off')
-- numbers
vim.opt.number = true
-- others
vim.opt.termguicolors = true
vim.opt.updatetime = 100
vim.opt.cursorline = true
vim.opt.autowrite = true
vim.opt.wrap = true
vim.opt.mouse = nil
vim.opt.keywordprg = "man"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.undofile = true
vim.opt.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"
vim.opt.inccommand = "split"
vim.opt.incsearch = true

-- fold
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.signcolumn = "yes"

-- tabs
vim.opt.shiftround = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.g.python_host_skip_check = 1
vim.g.python_host_prog = "/usr/bin/python3"
vim.g.python3_host_skip_check = 1
vim.g.python3_host_prog = "/usr/bin/python3"

vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	},
}

local ui2_ok, ui2 = pcall(require, "vim._core.ui2")
local extui_ok, extui = pcall(require, "vim._extui")
local plugins_loaded = false

if ui2_ok then
	ui2.enable({
		enable = true,
		msg = {
			targets = "cmd",
			msg = {
				timeout = 4000,
			},
		},
	})
elseif extui_ok then
	extui.enable({
		enable = true,
		msg = {
			target = "cmd",
			timeout = 4000,
		},
	})
end

if vim.g.shadowvim == nil and vim.g.vscode == nil then
	plugins_loaded = require("core.plugins").setup()

	if not plugins_loaded then
		require("core.theme").setup()
		require("nvim-surround").setup()
		require("config.lua_snip").config()
		require("config.lsp").config()
		require("config.lsp_misc").config()
		require("config.ufo").config()
		require("config.statusline").config()
		require("config.oil").config()
		require("config.terminal").config()
		require("config.treesitter").config()
		require("config.telescope").config()
		require("ibl").setup({
			indent = {
				char = "▏",
			},
			scope = {
				enabled = true,
				show_exact_scope = true,
			},
		})
		require("config.gitsigns").config()
	end
end
require("core.autocommand")
require("core.keymap")
require("core.clangd_index").setup()
