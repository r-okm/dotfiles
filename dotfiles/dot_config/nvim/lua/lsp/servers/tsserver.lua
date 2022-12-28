local M = {
  initOptions = {
    preferences = {
      importModuleSpecifierPreference = "non-relative",
      importModuleSpecifier = "non-relative",
    },
  },
  on_attach = function(client, bufnr)
    local lspKeymapToBuffer = require("lsp.utils.lspKeymapToBuffer")
    lspKeymapToBuffer(bufnr)

    client.server_capabilities.documentFormattingProvider = false
    -- typescript acitons organize imports などは null-ls のアクションに追加
    -- fix on save は eslint-lsp 側で設定
  end,
}

return M
