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
        local formatEnableServerNames = {
          "clangd",
          "lemminx",
          "rust_analyzer",
        }
        local isFormatEnable = false
        for _, server in ipairs(formatEnableServerNames) do
          if server == server_name then
            isFormatEnable = true
          end
        end

        lspconfig[server_name].setup({
          capabilities = capabilities,
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = isFormatEnable
          end,
        })
      end,
      ["tsserver"] = function()
        local typescript = require("typescript")
        typescript.setup({
          server = {
            init_options = {
              preferences = {
                importModuleSpecifierPreference = "non-relative",
                importModuleSpecifier = "non-relative",
              },
            },
            capabilities = capabilities,
            on_init = function(client)
              client.server_capabilities.documentFormattingProvider = false
            end,
            on_attach = function(_, bufnr)
              local organizeImports = function()
                typescript.actions.addMissingImports({ sync = true })
                typescript.actions.organizeImports({ sync = true })
              end
              local lintAndFormat = function()
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
                vim.cmd("write")
                vim.cmd("edit")
              end
              vim.keymap.set("n", "go", organizeImports)
              vim.keymap.set("n", "ge", lintAndFormat)
              vim.api.nvim_create_autocmd("BufWritePost", {
                group = vim.api.nvim_create_augroup("PreWriteTsserver", {}),
                buffer = bufnr,
                callback = lintAndFormat,
              })
            end,
          },
        })
      end,
      ["jdtls"] = function() end,
      ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
          settings = { Lua = { diagnostics = { globals = { "vim" } } } },
          capabilities = capabilities,
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        })
      end,
      ["sqls"] = function()
        lspconfig.sqls.setup({
          cmd = { "sqls", "-config", vim.loop.cwd() .. "/.nvim/sqls.config.yml" },
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            require("sqls").on_attach(client, bufnr)
          end,
        })
      end,
      ["jsonls"] = function()
        lspconfig.jsonls.setup({
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
          capabilities = capabilities,
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        })
      end,
      ["yamlls"] = function()
        lspconfig.yamlls.setup({
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
          capabilities = capabilities,
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        })
      end,
    })
  end,
}
