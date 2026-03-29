local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 設定ファイルの変更を自動で読み込む
config.automatically_reload_config = true

-- フォント
config.font = wezterm.font("MesloLGL Nerd Font")
config.font_size = 13.0
config.use_ime = true

-- 背景の透過度とぼかし
config.window_background_opacity = 0.75
config.macos_window_background_blur = 20

-- 非アクティブPaneを暗くして視認性を向上
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.1,
}

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

----------------------------------------------------
-- 別ファイルからの読み込み
----------------------------------------------------

require("tab").apply_to_config(config)
require("keybinds").apply_to_config(config)

return config
