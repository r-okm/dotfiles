local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local M = {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local lspKeymapToBuffer = require("lsp.utils.lspKeymapToBuffer")
    lspKeymapToBuffer(bufnr)

    client.server_capabilities.documentFormattingProvider = false
  end,
}

return M
