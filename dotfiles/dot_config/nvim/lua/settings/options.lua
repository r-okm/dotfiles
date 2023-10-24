local o = vim.o
local opt = vim.opt

o.clipboard = "unnamedplus"
o.whichwrap = "b,s,h,l,<,>,~,[,]"
o.smartcase = true
o.ignorecase = true
o.incsearch = true
o.hlsearch = true

-- vscode
if vim.g.vscode then
  -- print plugins
  vim.api.nvim_create_user_command("Plugins", function()
    vim.print(vim.tbl_keys(require("lazy.core.config").plugins))
  end, {})
else
  o.number = true
  o.relativenumber = true
  o.termgouicolors = true
  o.list = true
  opt.listchars = { tab = "»-", trail = "●", space = "⋅" }
  o.signcolumn = "yes"
  o.splitright = true

  -- [:H] => [:vert h]
  vim.api.nvim_create_user_command("H", function(opts)
    local command = string.format("vertical help %s", opts.args)
    vim.cmd(command)
  end, { nargs = 1, complete = "help" })
end

-- os のクリップボードと同期
local yank_command = os.getenv("YANK_COMMAND")
local paste_command = os.getenv("PASTE_COMMAND")
vim.g.clipboard = {
  name = "win32yank",
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
