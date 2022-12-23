return function()
  if vim.g.vscode then
    return
  end

  require('gruvbox').setup({
    italic = false,
  })
  vim.o.background = 'dark'
  vim.cmd([[colorscheme gruvbox]])
end
