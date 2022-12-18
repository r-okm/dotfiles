local opts = {
  on_attach_extra = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'EslintFixAll',
      desc = "[lsp] format on save",
    })
  end
}

return opts
