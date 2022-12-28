local M = {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas {
        select = {
          ".eslintrc",
          "docker-compose.yml",
          "package.json",
          "prettierrc.json",
          ".stylelintrc",
          "tsconfig.json",
        }
      },
      validate = { enable = true }
    }
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  on_attach = function(_, bufnr)
    local lspKeymapToBuffer = require("lsp.utils.lspKeymapToBuffer")
    lspKeymapToBuffer(bufnr)
  end,
}

return M
