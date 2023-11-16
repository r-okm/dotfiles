vim.opt.clipboard = "unnamedplus"
vim.opt.whichwrap = "b,s,h,l,<,>,~,[,]"
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.o.termgouicolors = true
vim.opt.list = true
vim.opt.listchars = { tab = "»-", trail = "●", space = " " }
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "yes"
vim.opt.splitright = true

-- [:H] => [:vert h]
vim.api.nvim_create_user_command("H", function(opts)
  local command = string.format("vertical help %s", opts.args)
  vim.cmd(command)
end, { nargs = 1, complete = "help" })

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
