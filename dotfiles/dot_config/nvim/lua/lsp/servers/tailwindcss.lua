local M = {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  root_dir = require("lspconfig.util").root_pattern("tailwind.config.js", "tailwind.config.ts")
}

return M
