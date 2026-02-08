local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font = wezterm.font("MesloLGL Nerd Font")
config.font_size = 13.0
config.use_ime = true
config.window_background_opacity = 0.75
config.macos_window_background_blur = 20

----------------------------------------------------
-- Tab
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
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

-- @see: https://wezterm.org/config/lua/wezterm/nerdfonts.html
-- アクティブタブにつけるアイコン
local ACTIVE_TAB_ICON = wezterm.nerdfonts.md_checkbox_marked_circle
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

-- タブの形をカスタマイズ
-- @see: https://wezterm.org/config/lua/window-events/format-tab-title.html
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#727169"
	local foreground = "#DCD7BA"
	local edge_background = "none"
	local left_arrow = SOLID_LEFT_ARROW
	if tab.is_active then
		background = "#FF9E3B"
		foreground = "#FFFFFF"
		left_arrow = ACTIVE_TAB_ICON .. "  " .. SOLID_LEFT_ARROW
	end
	local edge_foreground = background
	local title = "   "
		.. (tab.tab_index + 1)
		.. ": "
		.. wezterm.truncate_right(tab.active_pane.title, max_width - 1)
		.. "   "
	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = left_arrow },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
-- デフォルトのキーバインドを無効にする
config.disable_default_key_bindings = true
-- カスタムキーバインド設定を読み込んで反映する
local keybinds = require("keybinds")
config.leader = keybinds.leader
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables

-- どのキーモード中かを表示する
-- @see: https://wezterm.org/config/lua/window/set_right_status.html
wezterm.on("update-right-status", function(window, pane)
	local name = window:active_key_table()

	if not name then
		window:set_right_status("")
		return
	end

	window:set_right_status(wezterm.format({
		{ Background = { Color = "#FF9E3B" } },
		{ Foreground = { Color = "#FFFFFF" } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = "  MODE: " .. name .. "  " },
		{ Background = { Color = "none" } },
	}))
end)

return config
