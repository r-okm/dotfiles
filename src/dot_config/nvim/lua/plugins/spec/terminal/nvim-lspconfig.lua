return {
  "neovim/nvim-lspconfig",
  branch = "master",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "zapling/mason-lock.nvim",
    "jose-elias-alvarez/typescript.nvim",
    "b0o/schemastore.nvim",
    "mfussenegger/nvim-jdtls",
    "nanotee/sqls.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    require("mason-lock").setup({
      lockfile_path = vim.fn.stdpath("config") .. "/mason-lock.json",
    })
  end,
  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")
    local mlc = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

    mlc.setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["tsserver"] = function()
        local typescript = require("typescript")
        typescript.setup({
          server = {
            capabilities = capabilities,
            init_options = {
              preferences = {
                importModuleSpecifierPreference = "non-relative",
                importModuleSpecifier = "non-relative",
              },
            },
            on_attach = function(_, bufnr)
              vim.keymap.set("n", "go", function()
                typescript.actions.addMissingImports({ sync = false })
                typescript.actions.organizeImports({ sync = false })
              end, { buffer = bufnr })
              vim.keymap.set("n", "gf", function()
                vim.lsp.buf.format({
                  async = true,
                  bufnr = bufnr,
                  filter = function(format_client)
                    return format_client.name == "null-ls"
                  end,
                })
              end, { buffer = bufnr })
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("PreWriteTsserver" .. bufnr, {}),
                buffer = bufnr,
                callback = function()
                  pcall(function()
                    vim.cmd("EslintFixAll")
                  end)
                  typescript.actions.addMissingImports({ sync = true })
                  vim.lsp.buf.format({
                    async = false,
                    bufnr = bufnr,
                    filter = function(format_client)
                      return format_client.name == "null-ls"
                    end,
                  })
                end,
              })
            end,
          },
        })
      end,
      ["jdtls"] = function() end,
      ["sqls"] = function()
        lspconfig.sqls.setup({
          capabilities = capabilities,
          cmd = { "sqls", "-config", vim.loop.cwd() .. "/.nvim/sqls.config.yml" },
          on_attach = function(client, bufnr)
            require("sqls").on_attach(client, bufnr)
          end,
        })
      end,
      ["jsonls"] = function()
        lspconfig.jsonls.setup({
          capabilities = capabilities,
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        })
      end,
      ["yamlls"] = function()
        lspconfig.yamlls.setup({
          capabilities = capabilities,
          settings = {
            yaml = {
              schemaStore = {
                -- You must disable built-in schemaStore support if you want to use
                -- this plugin and its advanced options like `ignore`.
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
              },
              schemas = require("schemastore").yaml.schemas(),
              customTags = {
                "!Base64 scalar",
                "!Cidr scalar",
                "!And sequence",
                "!Equals sequence",
                "!If sequence",
                "!Not sequence",
                "!Or sequence",
                "!Condition scalar",
                "!FindInMap sequence",
                "!GetAtt scalar",
                "!GetAtt sequence",
                "!GetAZs scalar",
                "!ImportValue scalar",
                "!Join sequence",
                "!Select sequence",
                "!Split sequence",
                "!Sub scalar",
                "!Transform mapping",
                "!Ref scalar",
              },
            },
          },
        })
      end,
    })
  end,
}
