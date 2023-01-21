local M = {
  initOptions = {
    preferences = {
      importModuleSpecifierPreference = "non-relative",
      importModuleSpecifier = "non-relative",
    },
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  on_attach = function(_, bufnr)
    local getUtils = require("lsp.utils.getLspUtils")
    local utils = getUtils(bufnr, "null-ls")
    utils.setActionsKey()
    utils.setFmtKey()

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        local ts = require("typescript")
        ts.actions.addMissingImports({ sync = true })
        ts.actions.fixAll({ sync = true })
        vim.cmd("EslintFixAll")
      end,
    })
    -- typescript acitons organize imports などは null-ls のアクションに追加
  end,
}

return M
