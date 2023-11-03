vim.o.clipboard = "unnamedplus"
vim.o.whichwrap = "b,s,h,l,<,>,~,[,]"
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.hlsearch = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.termgouicolors = true
vim.o.list = true
vim.opt.listchars = { tab = "»-", trail = "●", space = "⋅" }
vim.o.signcolumn = "yes"
vim.o.splitright = true

-- [:H] => [:vert h]
local function verticalHelp()
  local command = string.format("vertical help %s", vim.opts.args)
  vim.cmd(command)
end
vim.api.nvim_create_user_command("H", verticalHelp, { nargs = 1, complete = "help" })

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
