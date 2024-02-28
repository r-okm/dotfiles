-- [:H] => [:vert h]
vim.api.nvim_create_user_command("H", function(opts)
  local command = string.format("vertical help %s", opts.args)
  vim.cmd(command)
end, { nargs = 1, complete = "help" })

-- quit 時にセッションファイルを作成する
local session_file_name = os.getenv("NEOVIM_SESSION_FILE_NAME") or "Session.vim"
vim.api.nvim_create_user_command("Q", function(_)
  local session_cmd = "mksession! " .. session_file_name
  local quit_cmd = "quitall!"

  vim.cmd(session_cmd)
  vim.cmd(quit_cmd)
end, {})

-- print plugins
local function printPlugins()
  vim.print(vim.tbl_keys(require("lazy.core.config").plugins))
end
vim.api.nvim_create_user_command("Plugins", printPlugins, {})
