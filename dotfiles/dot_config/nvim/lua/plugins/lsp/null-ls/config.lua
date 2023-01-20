return function()
  local mnl = require("mason-null-ls")
  local nls = require("null-ls")

  mnl.setup({
    ensure_installed = require("lsp.servers").null_ls,
  })
  nls.setup {
    diagnostics_format = "#{m} (#{s}: #{c})",
    sources = {
      nls.builtins.formatting.prettierd.with {
        prefer_local = "node_modules/.bin",
      },
      require("typescript.extensions.null-ls.code-actions"),
    },
  }
end
