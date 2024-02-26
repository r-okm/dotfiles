vim.opt.clipboard = "unnamedplus"
vim.opt.whichwrap = "b,s,h,l,<,>,~,[,]"
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.o.termguicolors = true
vim.opt.list = true
vim.opt.listchars = { tab = "»-", trail = "●", space = " " }
vim.opt.fillchars = vim.opt.fillchars + "diff: "
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.splitright = true

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

-- os のクリップボードと同期
local yank_command = os.getenv("YANK_COMMAND")
local paste_command = os.getenv("PASTE_COMMAND")
vim.g.clipboard = {
  name = "osClipboard",
  copy = {
    ["+"] = yank_command,
    ["*"] = yank_command,
  },
  paste = {
    ["+"] = paste_command,
    ["*"] = paste_command,
  },
  cache_enable = 0,
}

-- insert モードを抜けたときに IME を OFF
if vim.fn.executable("zenhan.exe") then
  vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, { command = "call system('zenhan.exe 0')" })
end
