-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- ----------------------------------------
-- 基本設定
-- ----------------------------------------
-- 文字コード
vim.scriptencoding = "utf-8"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- 日本語のスペルチェック
opt.spelllang = { "en", "cjk" }

-- バックアップとスワップファイルを作成しない
opt.backup = false
opt.swapfile = false

-- エラーメッセージでビープ音を鳴らさない
opt.errorbells = false

-- ----------------------------------------
-- 表示設定
-- ----------------------------------------
-- 行末の1文字先までカーソルを移動できるように
opt.virtualedit = "onemore"
