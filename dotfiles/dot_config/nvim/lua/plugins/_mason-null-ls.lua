return function()
  require('mason-null-ls').setup({
    ensure_installed = require('lsp.server_list').null_ls
  })
end
