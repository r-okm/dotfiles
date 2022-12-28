local M = {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  on_attach = function(client, bufnr)
    local lspKeymapToBuffer = require("lsp.utils.lspKeymapToBuffer")
    lspKeymapToBuffer(bufnr)

    client.server_capabilities.documentFormattingProvider = false
  end,
}

return M
