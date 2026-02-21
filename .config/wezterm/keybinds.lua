local wezterm = require("wezterm")
local act = wezterm.action

return {
	-- leaderキー
	leader = { key = ";", mods = "CTRL", timeout_milliseconds = 2000 },
	-- キーバインド @see: https://wezterm.org/config/keys.html
	keys = {
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
				action = wezterm.action_callback(function(win, pane, line)
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

		-- フォントサイズ切替
		{ key = "^", mods = "CTRL", action = act.IncreaseFontSize },
		{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
		-- フォントサイズのリセット
		{ key = "0", mods = "CTRL", action = act.ResetFontSize },

		-- コピー
		{ key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
		-- 貼り付け
		{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

		-- Panelサイズ調整
		{ key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
		-- コピーモード
		{ key = "c", mods = "LEADER", action = act.ActivateCopyMode },
	},
	-- キーテーブル @see: https://wezfurlong.org/wezterm/config/key-tables.html
	key_tables = {
		-- Panelサイズ調整 leader + s
		resize_pane = {
			{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
			{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
			{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
			{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },

			-- Panelサイズ調整を終了
			{ key = "Enter", action = "PopKeyTable" },
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
	},
}
