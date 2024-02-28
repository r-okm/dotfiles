return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre" },
  config = function()
    local nls = require("null-ls")
    local formatting = nls.builtins.formatting
    local diagnostics = nls.builtins.diagnostics

    nls.setup({
      -- diagnostics_format = "#{m} (#{s}: #{c})",
      sources = {
        formatting.prettierd.with({
          prefer_local = "node_modules/.bin",
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/prettier/.prettierrc.json"),
          },
        }),
        formatting.stylua,
        diagnostics.hadolint,
      },
      on_attach = function(client, bufnr)
        local formatEnableFiletypes = { "lua", "json", "jsonc", "yaml" }
        for _, ft in ipairs(formatEnableFiletypes) do
          if vim.bo[bufnr].filetype == ft and client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("PreWriteNls" .. bufnr, {}),
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(format_client)
                    return format_client.name == "null-ls"
                  end,
                })
              end,
            })
          end
        end
      end,
    })
  end,
}
