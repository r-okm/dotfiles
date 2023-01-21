local M = {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  root_dir = require("lspconfig.util").root_pattern("next.config.js")
}

return M
