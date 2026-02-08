-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 設定ファイル自動リロード
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.stdpath("config") .. "/lua/**/*.lua",
  callback = function()
    vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
    vim.notify("設定を再読み込みしました", vim.log.levels.INFO)
  end,
})

-- ファイルの自動リロード設定
vim.api.nvim_create_augroup("auto_reload", { clear = true })
-- フォーカスを得た時、バッファに入った時、カーソルを動かさず放置した時に自動リロード
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = "auto_reload",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})
