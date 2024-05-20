-- ヘルプコマンドを垂直分割で表示する
local function openHelpVertically(opts)
  local command = string.format("vertical help %s", opts.args)
  vim.cmd(command)
end
vim.api.nvim_create_user_command("H", openHelpVertically, { nargs = 1, complete = "help" })

-- 終了時にセッションファイルを作成する
local function saveSessionAndQuit(_)
  local session_file_name = os.getenv("NEOVIM_SESSION_FILE_NAME") or "Session.vim"
  local session_cmd = "mksession! " .. session_file_name
  local quit_cmd = "quitall!"

  vim.cmd(session_cmd)
  vim.cmd(quit_cmd)
end
vim.api.nvim_create_user_command("Q", saveSessionAndQuit, {})

-- プラグインを表示する
local function printPlugins()
  vim.print(vim.tbl_keys(require("lazy.core.config").plugins))
end
vim.api.nvim_create_user_command("Plugins", printPlugins, {})

-- chezmoi applyを実行する
-- カレントディレクトリが ~/.local/share/chezmoi の場合のみ有効
local current_dir = vim.fn.expand("%:p:h")
if current_dir == os.getenv("HOME") .. "/.local/share/chezmoi" then
  local function applyChezmoi()
    vim.cmd("silent !chezmoi apply")
  end
  vim.api.nvim_create_user_command("ChezmoiApply", applyChezmoi, {})
  vim.api.nvim_create_user_command("ChezmoiApplyQuit", function()
    applyChezmoi()
    vim.cmd("quitall!")
  end, {})
  vim.api.nvim_create_user_command("ChezmoiApplyQuitSaveSession", function()
    applyChezmoi()
    vim.cmd("Q")
  end, {})
end
