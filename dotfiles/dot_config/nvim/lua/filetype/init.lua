local ft_configs = require("filetype.configs")

vim.api.nvim_create_augroup("vimrc_augroup", {})
vim.api.nvim_create_autocmd("FileType", {
  group = "vimrc_augroup",
  pattern = "*",
  callback = function(args) ft_configs[args.match]() end
})
