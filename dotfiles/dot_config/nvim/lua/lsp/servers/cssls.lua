local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local M = {
  capabilities = capabilities,
  on_attach = function(_, bufnr)
    local getUtils = require("lsp.utils.getLspUtils")
    local utils = getUtils(bufnr, "null-ls")
    utils.setActionsKey()
    utils.setFmtKey()
    utils.setFmtOnSave()
  end,
}

return M
