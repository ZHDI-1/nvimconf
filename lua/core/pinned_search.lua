local M = {}

local MATCH_PRIORITY = 100
local HIGHLIGHT_VARIANTS = 8
local state_by_window = {}

local theme_highlights = {
	"Search",
	"IncSearch",
}

local variant_adjustments = {
	{ hue = -0.04, saturation = 0.01, lightness = -0.08 },
	{ hue = -0.007, saturation = 0.02, lightness = -0.025 },
	{ hue = 0.007, saturation = -0.01, lightness = 0.025 },
	{ hue = 0.02, saturation = -0.02, lightness = 0.08 },
}

local function clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

local function get_highlight(name)
	local ok, highlight = pcall(vim.api.nvim_get_hl, 0, {
		name = name,
		link = true,
	})

	if ok then
		return highlight
	end

	return {}
end

local function is_usable_color(color)
	return type(color) == "number" and color ~= 0
end

local function color_to_rgb(color)
	return math.floor(color / 0x10000) % 0x100,
		math.floor(color / 0x100) % 0x100,
		color % 0x100
end

local function rgb_to_hsl(color)
	local red, green, blue = color_to_rgb(color)
	red, green, blue = red / 255, green / 255, blue / 255

	local maximum = math.max(red, green, blue)
	local minimum = math.min(red, green, blue)
	local lightness = (maximum + minimum) / 2

	if maximum == minimum then
		return 0, 0, lightness
	end

	local delta = maximum - minimum
	local saturation = lightness > 0.5 and delta / (2 - maximum - minimum)
		or delta / (maximum + minimum)
	local hue

	if maximum == red then
		hue = (green - blue) / delta + (green < blue and 6 or 0)
	elseif maximum == green then
		hue = (blue - red) / delta + 2
	else
		hue = (red - green) / delta + 4
	end

	return hue / 6, saturation, lightness
end

local function hue_to_rgb(p, q, hue)
	if hue < 0 then
		hue = hue + 1
	elseif hue > 1 then
		hue = hue - 1
	end

	if hue < 1 / 6 then
		return p + (q - p) * 6 * hue
	elseif hue < 1 / 2 then
		return q
	elseif hue < 2 / 3 then
		return p + (q - p) * (2 / 3 - hue) * 6
	end

	return p
end

local function hsl_to_rgb(hue, saturation, lightness)
	local red, green, blue

	if saturation == 0 then
		red, green, blue = lightness, lightness, lightness
	else
		local q = lightness < 0.5
			and lightness * (1 + saturation)
			or lightness + saturation - lightness * saturation
		local p = 2 * lightness - q

		red = hue_to_rgb(p, q, hue + 1 / 3)
		green = hue_to_rgb(p, q, hue)
		blue = hue_to_rgb(p, q, hue - 1 / 3)
	end

	return math.floor(clamp(red, 0, 1) * 255 + 0.5) * 0x10000
		+ math.floor(clamp(green, 0, 1) * 255 + 0.5) * 0x100
		+ math.floor(clamp(blue, 0, 1) * 255 + 0.5)
end

local function variant_background(base_color, index)
	local hue, saturation, lightness = rgb_to_hsl(base_color)
	local adjustment = variant_adjustments[index]

	return hsl_to_rgb(
		(hue + adjustment.hue) % 1,
		clamp(saturation + adjustment.saturation, 0, 1),
		clamp(lightness + adjustment.lightness, 0.08, 0.92)
	)
end

local function setup_highlights()
	local normal = get_highlight("Normal")
	local backgrounds = {}
	local default_foreground = normal.fg

	for _, name in ipairs(theme_highlights) do
		local highlight = get_highlight(name)
		if is_usable_color(highlight.bg) then
			table.insert(backgrounds, {
				bg = highlight.bg,
				fg = highlight.fg,
			})
		end

		if not is_usable_color(default_foreground) and is_usable_color(highlight.fg) then
			default_foreground = highlight.fg
		end
	end

	if #backgrounds == 0 and is_usable_color(normal.fg) then
		table.insert(backgrounds, {
			bg = normal.fg,
			fg = is_usable_color(normal.bg) and normal.bg or nil,
		})
	end

	if #backgrounds == 0 then
		for index = 1, HIGHLIGHT_VARIANTS do
			vim.api.nvim_set_hl(0, "PinnedSearch" .. index, {
				link = "Search",
			})
		end
		return
	end

	for index = 1, HIGHLIGHT_VARIANTS do
		local source_index = ((index - 1) % #backgrounds) + 1
		local variant_index = math.floor((index - 1) / #backgrounds) + 1
		local source = backgrounds[source_index]
		local foreground = is_usable_color(source.fg) and source.fg or default_foreground
		if not is_usable_color(foreground) and is_usable_color(normal.bg) then
			foreground = normal.bg
		end

		local options = {
			bg = variant_background(source.bg, variant_index),
			bold = true,
		}

		if foreground ~= nil then
			options.fg = foreground
		end

		vim.api.nvim_set_hl(0, "PinnedSearch" .. index, options)
	end
end

local function get_state(window)
	window = window or vim.api.nvim_get_current_win()

	if not state_by_window[window] then
		state_by_window[window] = {
			matches = {},
			selected = nil,
		}
	end

	return window, state_by_window[window]
end

local function find_pattern(state, pattern)
	for index, item in ipairs(state.matches) do
		if item.pattern == pattern then
			return index
		end
	end

	return nil
end

local function remove_at(window, state, index)
	local item = table.remove(state.matches, index)
	if not item then
		return nil
	end

	if vim.api.nvim_win_is_valid(window) then
		pcall(vim.fn.matchdelete, item.id, window)
	end

	if #state.matches == 0 then
		state.selected = nil
	elseif state.selected == nil then
		state.selected = math.min(index, #state.matches)
	elseif state.selected > index then
		state.selected = state.selected - 1
	elseif state.selected > #state.matches then
		state.selected = #state.matches
	end

	return item
end

local function add_pattern(pattern, label)
	local _, state = get_state()
	local existing = find_pattern(state, pattern)

	if existing then
		state.selected = existing
		vim.notify(("Pattern already pinned and selected: /%s/"):format(label or pattern))
		return
	end

	local color_index = (#state.matches % HIGHLIGHT_VARIANTS) + 1
	local ok, match_id = pcall(vim.fn.matchadd, "PinnedSearch" .. color_index, pattern, MATCH_PRIORITY)

	if not ok or type(match_id) ~= "number" or match_id < 0 then
		local reason = ok and ("matchadd returned " .. tostring(match_id)) or tostring(match_id)
		vim.notify("Invalid search pattern: " .. reason, vim.log.levels.ERROR)
		return
	end

	table.insert(state.matches, {
		id = match_id,
		pattern = pattern,
		label = label or pattern,
	})
	state.selected = #state.matches

	vim.notify(("Pinned #%d /%s/"):format(state.selected, label or pattern))
end

function M.pin_current_search()
	local pattern = vim.fn.getreg("/")

	if pattern == "" then
		vim.notify("No current search pattern", vim.log.levels.WARN)
		return
	end

	add_pattern(pattern)
end

function M.toggle_cursor_word()
	local word = vim.fn.expand("<cword>")

	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local escaped_word = vim.fn.escape(word, [[\.^$~[]*]])
	local pattern = "\\<" .. escaped_word .. "\\>"
	local window, state = get_state()
	local existing = find_pattern(state, pattern)

	if existing then
		remove_at(window, state, existing)
		vim.notify("Unpinned word /" .. word .. "/")
		return
	end

	add_pattern(pattern, word)
end

function M.select_next()
	local _, state = get_state()

	if #state.matches == 0 then
		vim.notify("No pinned searches")
		return
	end

	state.selected = ((state.selected or 0) % #state.matches) + 1
	local item = state.matches[state.selected]
	vim.notify(("Selected #%d /%s/"):format(state.selected, item.label))
end

function M.select_previous()
	local _, state = get_state()

	if #state.matches == 0 then
		vim.notify("No pinned searches")
		return
	end

	local current = state.selected or 1
	state.selected = ((current - 2) % #state.matches) + 1
	local item = state.matches[state.selected]
	vim.notify(("Selected #%d /%s/"):format(state.selected, item.label))
end

local function jump(direction)
	local _, state = get_state()
	local item = state.matches[state.selected or 0]

	if not item then
		vim.notify("No pinned search selected")
		return
	end

	if vim.fn.search(item.pattern, direction .. "W") == 0 then
		vim.notify("No match for /" .. item.label .. "/", vim.log.levels.WARN)
	end
end

function M.jump_next()
	jump("")
end

function M.jump_previous()
	jump("b")
end

function M.remove_selected()
	local window, state = get_state()
	local selected = state.selected

	if not selected or not state.matches[selected] then
		vim.notify("No pinned search selected")
		return
	end

	local item = remove_at(window, state, selected)
	vim.notify("Removed /" .. item.label .. "/")
end

function M.clear()
	local window, state = get_state()

	for _, item in ipairs(state.matches) do
		if vim.api.nvim_win_is_valid(window) then
			pcall(vim.fn.matchdelete, item.id, window)
		end
	end

	state.matches = {}
	state.selected = nil
	vim.notify("Cleared pinned searches")
end

local group = vim.api.nvim_create_augroup("pinned_search", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = setup_highlights,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	callback = setup_highlights,
})

vim.api.nvim_create_autocmd("WinClosed", {
	group = group,
	callback = function(args)
		state_by_window[tonumber(args.match)] = nil
	end,
})

setup_highlights()

return M
