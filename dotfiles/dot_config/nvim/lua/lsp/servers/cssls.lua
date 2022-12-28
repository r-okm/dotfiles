local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local M = {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local lspKeymapToBuffer = require("lsp.utils.lspKeymapToBuffer")
    lspKeymapToBuffer(bufnr)

    client.server_capabilities.documentFormattingProvider = false
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          filter = function(fmt_client)
            return fmt_client.name == "null-ls"
          end
        })
      end,
      desc = "[lsp] format on save",
    })
  end,
}

return M
