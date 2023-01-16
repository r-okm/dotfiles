local o = vim.o
local opt = vim.opt

o.whichwrap = "b,s,h,l,<,>,~,[,]"
o.smartcase = true
o.ignorecase = true
o.clipboard = "unnamedplus"

-- not vscode
if not vim.g.vscode then
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

  -- 下部ペインとサイドペインを表示するコマンド
  vim.api.nvim_create_user_command("Ide", function()
    vim.cmd("Trouble")
    vim.cmd("NvimTreeOpen")
    vim.cmd("wincmd w")
  end, {})
end

-- wsl でホストとクリップボードを共有
local win32yank = "/mnt/c/scoop/shims/win32yank.exe"
if vim.fn.has("wsl") and vim.fn.executable(win32yank) then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = win32yank .. " -i --crlf",
      ["*"] = win32yank .. " -i --crlf",
    },
    paste = {
      ["+"] = win32yank .. " -o --lf",
      ["*"] = win32yank .. " -o --lf",
    },
    cache_enable = 0,
  }
end
