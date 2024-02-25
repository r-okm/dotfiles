return {
  "neovim/nvim-lspconfig",
  event = { "BUfReadPre" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "zapling/mason-lock.nvim",
    "jose-elias-alvarez/typescript.nvim",
    "b0o/schemastore.nvim",
  },
  init = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local tb = require("telescope.builtin")

        -- Buffer local mappings.
        local opts = { buffer = ev.buf }

        -- diagnostic
        vim.keymap.set("n", "g.", "<cmd>Lspsaga diagnostic_jump_next<CR>")
        vim.keymap.set("n", "g,", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
        vim.keymap.set("n", "gw", function()
          tb.diagnostics({ bufnr = 0 })
        end)
        vim.keymap.set("n", "gW", function()
          tb.diagnostics({ bufnr = nil })
        end)
        vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
        -- code navigation
        vim.keymap.set("n", "gd", function()
          tb.lsp_definitions()
        end, opts)
        vim.keymap.set("n", "gD", function()
          tb.lsp_implementations()
        end, opts)
        vim.keymap.set("n", "gt", function()
          tb.lsp_type_definitions()
        end, opts)
        vim.keymap.set("n", "grr", function()
          tb.lsp_references()
        end, opts)
        -- hover code action
        vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
        -- symbol rename
        vim.keymap.set("n", "grn", "<cmd>Lspsaga rename<CR>", opts)
        -- format
        vim.keymap.set("n", "gf", function()
          vim.lsp.buf.format({ async = true })
        end, opts)
        -- code action
        vim.keymap.set({ "n", "v" }, "ga", "<cmd>Lspsaga code_action<CR>", opts)

        -- setup diagnostic signs
        local signs = {
          Error = " ",
          Warn = " ",
          Info = " ",
          Hint = " ",
        }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        local function diagnostic_formatter(diagnostic)
          return string.format("[%s] %s (%s)", diagnostic.message, diagnostic.source, diagnostic.code)
        end
        vim.diagnostic.config({
          virtual_text = true,
          severity_sort = true,
          underline = false,
          signs = true,
          update_in_insert = false,
          float = { sformat = diagnostic_formatter },
        })
      end,
    })

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

    mlc.setup({
      ensure_installed = {
        "clangd",
        "eslint",
        "jsonls",
        "lua_ls",
        "tsserver",
        "yamlls",
      },
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

    lspconfig.efm.setup({
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "lua",
        "json",
        "jsonc",
        "yaml",
        "dockerfile",
      },
      on_attach = function(_, bufnr)
        local formatEnableFiletypes = { "lua", "json", "jsonc", "yaml" }
        for _, ft in ipairs(formatEnableFiletypes) do
          if vim.bo[bufnr].filetype == ft then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("PreWriteEfm", {}),
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format()
              end,
            })
          end
        end
      end,
    })
    mlc.setup_handlers({
      function(server_name)
        local formatEnableServerNames = {
          "clangd",
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
          on_attach = function(_, bufnr)
            if isFormatEnable then
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("PreWriteGeneralLsp", {}),
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format()
                end,
              })
            end
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
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("PreWriteTsserver", {}),
                buffer = bufnr,
                callback = function()
                  vim.cmd("EslintFixAll")
                  typescript.actions.addMissingImports({ sync = true })
                  typescript.actions.organizeImports({ sync = true })
                  vim.lsp.buf.format({
                    async = false,
                    bufnr = bufnr,
                  })
                end,
              })
            end,
          },
        })
      end,
      ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
          settings = { Lua = { diagnostics = { globals = { "vim" } } } },
          capabilities = capabilities,
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
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