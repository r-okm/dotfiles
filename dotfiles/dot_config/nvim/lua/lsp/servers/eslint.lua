local M = {
  on_attach = function(client, bufnr)
    local lspKeymapToBuffer = require("lsp.utils.lspKeymapToBuffer")
    lspKeymapToBuffer(bufnr)

    client.server_capabilities.documentFormattingProvider = false
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        require("typescript").actions.fixAll({ sync = true })
        vim.cmd("EslintFixAll")
      end,
      desc = "[lsp] eslint/typescript fix all on save",
    })
  end,
}

return M
