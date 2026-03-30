local wezterm = require("wezterm")
local module = {}

-- Custom tab titles (tab_id -> string or nil)
module.custom_title = {}

----------------------------------------------------
-- 定数
----------------------------------------------------

-- @see https://wezterm.org/config/lua/wezterm/nerdfonts.html
local ICONS = {
	claude = wezterm.nerdfonts.md_asterisk,
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

local function is_claude_process(process_name, pane_title)
	return process_name == "claude" or (pane_title and (pane_title:find("^✳") or pane_title:lower():find("claude")))
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

local function get_icon_and_color(process_name, pane_title)
	if pane_title == "nvim" or process_name == "nvim" then
		return ICONS.neovim, ICON_COLORS.neovim
	end

	if is_claude_process(process_name, pane_title) then
		return ICONS.claude, ICON_COLORS.claude
	end

	return ICONS.fallback, TAB_COLORS.foreground_inactive
end

local function get_pane_title_text(tab)
	local custom_title = tab.tab_title or ""
	if custom_title ~= "" then
		return custom_title
	end

	return tab.active_pane.title or ""
end

----------------------------------------------------
-- メイン処理
----------------------------------------------------

function module.apply_to_config(config)
	-- タブバーの表示
	config.show_tabs_in_tab_bar = true
	-- タブが一つの時は非表示
	config.hide_tab_bar_if_only_one_tab = true

	-- タブバーの透過
	config.window_frame = {
		inactive_titlebar_bg = "none",
		active_titlebar_bg = "none",
	}

	-- タブバーを背景色に合わせる
	config.window_background_gradient = {
		colors = { "#000000" },
	}

	-- タブの追加ボタンを非表示
	config.show_new_tab_button_in_tab_bar = false

	-- タブ同士の境界線を非表示
	config.colors = {
		tab_bar = {
			inactive_tab_edge = "none",
		},
	}

	-- タブの形をカスタマイズ
	-- @see: https://wezterm.org/config/lua/window-events/format-tab-title.html
	wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
		local pane = tab.active_pane
		local pane_title = pane.title or ""
		local process_name = basename(pane.foreground_process_name or "")

		-- タブの色
		local background, foreground = get_tab_colors(tab.is_active)
		local edge_background = "transparent"
		local edge_foreground = background

		-- タブの形
		local left_arrow, right_arrow = get_arrows(tab.is_active)

		-- ズームインジケーター
		local zoom_indicator = pane.is_zoomed and (ICONS.zoom .. "   ") or ""

		-- アイコン
		local icon, icon_color = get_icon_and_color(process_name, pane_title)

		-- タブのタイトル
		local title = wezterm.truncate_right(get_pane_title_text(tab), max_width)
		local title_suffix = ICONS.command .. "  " .. (tab.tab_index + 1)

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
			{ Text = "   " },
			{ Text = title },
			{ Attribute = { Intensity = "Normal" } },
			{ Text = "     " },
			{ Text = title_suffix },
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = right_arrow },
		}
	end)
end

return module
