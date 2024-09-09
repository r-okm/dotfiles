return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
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
        diagnostics.cfn_lint,
        diagnostics.hadolint,
        diagnostics.markdownlint,
      },
      on_attach = function(_, bufnr)
        local filtype_configs = {
          -- typescript は vtsls で設定するため未記載
          ["css"] = {
            format_cmd_enable = true,
            format_on_save = true,
          },
          ["lua"] = {
            format_cmd_enable = true,
            format_on_save = true,
          },
          ["json"] = {
            format_cmd_enable = true,
            format_on_save = true,
          },
          ["jsonc"] = {
            format_cmd_enable = true,
            format_on_save = true,
          },
          ["markdown"] = {
            format_cmd_enable = true,
            format_on_save = true,
          },
          ["yaml"] = {
            format_cmd_enable = true,
            format_on_save = true,
          },
        }

        local format_cmd_enable = false
        local format_on_save = false
        for ft, config in pairs(filtype_configs) do
          if vim.bo[bufnr].filetype == ft then
            format_cmd_enable = config.format_cmd_enable
            format_on_save = config.format_on_save
            break
          end
        end

        if format_cmd_enable then
          vim.keymap.set("n", "gf", function()
            vim.lsp.buf.format({
              async = true,
              bufnr = bufnr,
              filter = function(format_client)
                return format_client.name == "null-ls"
              end,
            })
          end, { buffer = bufnr })
        end
        if format_on_save then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("PreWriteNls" .. bufnr, {}),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                async = false,
                bufnr = bufnr,
                filter = function(format_client)
                  return format_client.name == "null-ls"
                end,
              })
            end,
          })
        end
      end,
    })
  end,
}
