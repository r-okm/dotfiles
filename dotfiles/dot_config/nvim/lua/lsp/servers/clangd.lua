local M = {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  on_attach = function(_, bufnr)
    local getUtils = require("lsp.utils.getLspUtils")
    local utils = getUtils(bufnr, "clangd")
    utils.setActionsKey()
    utils.setFmtKey()
    utils.setFmtOnSave()
  end,
}

return M
