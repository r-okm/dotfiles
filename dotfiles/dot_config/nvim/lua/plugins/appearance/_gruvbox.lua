return function()
  require('gruvbox').setup({
    italic = false,
  })
  vim.o.background = 'dark'
  vim.cmd([[colorscheme gruvbox]])
end
