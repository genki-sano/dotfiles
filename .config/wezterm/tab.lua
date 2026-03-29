local wezterm = require("wezterm")
local module = {}

-- Custom tab titles (tab_id -> string or nil)
module.custom_title = {}

----------------------------------------------------
-- 定数
----------------------------------------------------

-- @see https://wezterm.org/config/lua/wezterm/nerdfonts.html
local ICONS = {
	claude = "✳",
	neovim = wezterm.nerdfonts.linux_neovim,
	fallback = wezterm.nerdfonts.cod_terminal,
	zoom = wezterm.nerdfonts.md_arrow_expand,
	command = wezterm.nerdfonts.md_apple_keyboard_command,
}

local ICON_COLORS = {
	claude = "#D97757",
	neovim = "#57A143",
}

local TAB_COLORS = {
	foreground_inactive = "#a0a9cb",
	background_inactive = "none",
	foreground_active = "#313244",
	background_active = "#80EBDF",
}

local DECORATIONS = {
	left_circle = wezterm.nerdfonts.ple_left_half_circle_thick,
	right_circle = wezterm.nerdfonts.ple_right_half_circle_thick,
}

----------------------------------------------------
-- ヘルパー関数
----------------------------------------------------

local function basename(path)
	return string.gsub(path or "", "(.*[/\\])(.*)", "%2")
end

local function get_tab_colors(is_active)
	if is_active then
		return TAB_COLORS.background_active, TAB_COLORS.foreground_active
	end

	return TAB_COLORS.background_inactive, TAB_COLORS.foreground_inactive
end

local function get_arrows(is_active)
	if is_active then
		return DECORATIONS.left_circle, DECORATIONS.right_circle
	end

	return "", ""
end

local function get_icon_and_color(process_name, pane_title, is_claude)
	if pane_title == "nvim" or process_name == "nvim" then
		return ICONS.neovim, ICON_COLORS.neovim
	end

	if is_claude then
		return ICONS.claude, ICON_COLORS.claude
	end

	return ICONS.fallback, TAB_COLORS.foreground_inactive
end

local function get_pane_title_text(tab)
	local tab_title = tab.tab_title
	if tab_title == "" then
		return tab.active_pane.title or ""
	end

	return tab_title
end

----------------------------------------------------
-- メイン処理
----------------------------------------------------

function module.apply_to_config(_)
	-- タブの形をカスタマイズ
	-- @see: https://wezterm.org/config/lua/window-events/format-tab-title.html
	wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
		local pane = tab.active_pane
		local pane_title = get_pane_title_text(tab)

		-- タブの色
		local background, foreground = get_tab_colors(tab.is_active)
		local edge_background = "transparent"
		local edge_foreground = background

		-- タブの形
		local left_arrow, right_arrow = get_arrows(tab.is_active)

		-- ズームインジケーター
		local zoom_indicator = pane.is_zoomed and (ICONS.zoom .. "   ") or ""

		-- アイコン
		local icon, icon_color = get_icon_and_color(basename(pane.foreground_process_name), pane.title or "", false)

		-- タブのタイトル
		local title = "   "
			.. wezterm.truncate_right(pane_title, max_width)
			.. "     "
			.. ICONS.command
			.. "  "
			.. (tab.tab_index + 1)

		return {
			{ Background = { Color = edge_background } },
			{ Text = " " },
			{ Foreground = { Color = edge_foreground } },
			{ Text = left_arrow },
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = zoom_indicator },
			{ Foreground = { Color = icon_color } },
			{ Text = icon },
			{ Foreground = { Color = foreground } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = title },
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = right_arrow },
		}
	end)
end

return module
