local M = {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }
      },
    },
  },
  on_attach = function(_, bufnr)
    local lspKeymapToBuffer = require("lsp.utils.lspKeymapToBuffer")
    lspKeymapToBuffer(bufnr)

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
      desc = "[lsp] format on save",
    })
  end,
}

return M
