local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 設定ファイルの変更を自動で読み込む
config.automatically_reload_config = true

-- フォント
config.font = wezterm.font("HackGen Console NF")
config.font_size = 15.0
config.use_ime = true

-- 背景の透過度とぼかし
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20

-- 非アクティブPaneを暗くして視認性を向上
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.1,
}

-- タイトルバーを非表示
config.window_decorations = "RESIZE"

----------------------------------------------------
-- 別ファイルからの読み込み
----------------------------------------------------

require("tab").apply_to_config(config)
require("keymaps").apply_to_config(config)

return config
