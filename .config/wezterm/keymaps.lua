local wezterm = require("wezterm")
local module = {}

local act = wezterm.action

----------------------------------------------------
-- 定数
----------------------------------------------------

local OPACITY = {
	defalult = 0.9,
	step = 0.05,
	min = 0.20,
	max = 1.00,
}

----------------------------------------------------
-- ヘルパー関数
----------------------------------------------------

local function clamp(v, min, max)
	return math.max(min, math.min(max, v))
end

local function current_opacity(window)
	local overrides = window:get_config_overrides() or {}
	return overrides.window_background_opacity or OPACITY.defalult
end

wezterm.on("opacity-decrease", function(window, _)
	local opacity = clamp(current_opacity(window) - OPACITY.step, OPACITY.min, OPACITY.max)
	local overrides = window:get_config_overrides() or {}
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

wezterm.on("opacity-increase", function(window, _)
	local opacity = clamp(current_opacity(window) + OPACITY.step, OPACITY.min, OPACITY.max)
	local overrides = window:get_config_overrides() or {}
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

wezterm.on("opacity-reset", function(window, _)
	local overrides = window:get_config_overrides() or {}
	overrides.window_background_opacity = OPACITY.defalult
	window:set_config_overrides(overrides)
end)

----------------------------------------------------
-- メイン処理
----------------------------------------------------

-- leaderキー
local leader = { key = ";", mods = "CTRL", timeout_milliseconds = 2000 }

-- キーバインド @see: https://wezterm.org/config/keys.html
local keys = {
	-- コマンドパレット
	{ key = "p", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
	-- 設定再読み込み
	{ key = "r", mods = "SHIFT|CTRL", action = act.ReloadConfiguration },
	-- アプリケーションを終了
	{ key = "q", mods = "SUPER", action = act.QuitApplication },

	-- workspaceの切り替え
	{
		key = "w",
		mods = "LEADER",
		action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }),
	},
	-- workspaceの名前変更
	{
		key = "$",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "(wezterm) Set workspace title:",
			action = wezterm.action_callback(function(_, _, line)
				if line then
					wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
				end
			end),
		}),
	},
	-- workspaceの作成
	{
		key = "W",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = "(wezterm) Create new workspace:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},

	-- Tab名変更 lerader + ,
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "(wezterm) Rename tab (empty to reset):",
			action = wezterm.action_callback(function(_, pane, line)
				if line == nil then
					return
				end

				pane:tab():set_title(line)
			end),
		}),
	},
	-- Tab移動
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
	-- Tab入れ替え
	{ key = "{", mods = "LEADER", action = act({ MoveTabRelative = -1 }) },
	-- Tab新規作成
	{ key = "t", mods = "SUPER", action = act({ SpawnTab = "CurrentPaneDomain" }) },
	-- Tabを閉じる
	{ key = "w", mods = "SUPER", action = act({ CloseCurrentTab = { confirm = true } }) },
	{ key = "}", mods = "LEADER", action = act({ MoveTabRelative = 1 }) },
	-- Tab切替 Cmd + 数字
	{ key = "1", mods = "SUPER", action = act.ActivateTab(0) },
	{ key = "2", mods = "SUPER", action = act.ActivateTab(1) },
	{ key = "3", mods = "SUPER", action = act.ActivateTab(2) },
	{ key = "4", mods = "SUPER", action = act.ActivateTab(3) },
	{ key = "5", mods = "SUPER", action = act.ActivateTab(4) },
	{ key = "6", mods = "SUPER", action = act.ActivateTab(5) },
	{ key = "7", mods = "SUPER", action = act.ActivateTab(6) },
	{ key = "8", mods = "SUPER", action = act.ActivateTab(7) },
	{ key = "9", mods = "SUPER", action = act.ActivateTab(-1) },

	-- Pane作成 leader + r or d
	{ key = "d", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "r", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- Paneを閉じる leader + x
	{ key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },
	-- Pane移動 leader + hlkj
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	-- Pane選択
	{ key = "[", mods = "CTRL|SHIFT", action = act.PaneSelect },
	-- 選択中のPaneのみ表示
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- フォントサイズの変更
	{ key = "^", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },

	-- 背景透過度の変更
	{ key = "-", mods = "SUPER", action = act.EmitEvent("opacity-decrease") },
	{ key = ";", mods = "SUPER", action = act.EmitEvent("opacity-increase") },
	{ key = "0", mods = "SUPER", action = act.EmitEvent("opacity-reset") },

	-- コピー
	{ key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
	-- 貼り付け
	{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

	-- Claude Codeで改行できるように
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },

	-- 設定モード
	{ key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "setting_mode", one_shot = false }) },
	-- コピーモード
	{ key = "c", mods = "LEADER", action = act.ActivateCopyMode },
}

-- キーテーブル @see: https://wezfurlong.org/wezterm/config/key-tables.html
local key_tables = {
	-- 設定モード leader + s
	setting_mode = {
		-- Paneサイズの調整
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },

		-- 設定モードの終了
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "c", mods = "CTRL", action = "PopKeyTable" },
	},
	-- コピーモード leader + c
	copy_mode = {
		-- 移動
		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
		-- 最初と最後に移動
		{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
		-- 左端に移動
		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
		--
		{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
		-- 単語ごと移動
		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
		{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
		-- ジャンプ機能 t f
		{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
		{ key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
		{ key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
		-- 一番下へ
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
		-- 一番上へ
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		-- viweport
		{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
		{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
		{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
		-- スクロール
		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
		{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
		-- 範囲選択モード
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
		{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		-- コピー
		{ key = "y", mods = "NONE", action = act.CopyTo("Clipboard") },

		-- コピーモードを終了
		{
			key = "Enter",
			mods = "NONE",
			action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
		},
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
	},
}

function module.apply_to_config(config)
	-- デフォルトのキーバインドを無効にする
	config.disable_default_key_bindings = true

	-- カスタムキーバインド設定を読み込んで反映する
	config.keys = keys
	config.key_tables = key_tables
	config.leader = leader

	-- どのキーモード中かを表示する
	-- @see: https://wezterm.org/config/lua/window/set_right_status.html
	wezterm.on("update-right-status", function(window, _)
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
end

return module
