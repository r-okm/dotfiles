-- set options
local o = vim.o

o.whichwrap = 'b,s,h,l,<,>,~,[,]'
o.smartcase = true
o.ignorecase = true
o.clipboard = 'unnamedplus'

-- wsl でホストとクリップボードを共有
local win32yank = '/mnt/c/scoop/shims/win32yank.exe'
if vim.fn.has('wsl') and vim.fn.executable(win32yank) then
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

-- vscode
if vim.g.vscode then

else
  o.number = true
  o.relativenumber = true
end
