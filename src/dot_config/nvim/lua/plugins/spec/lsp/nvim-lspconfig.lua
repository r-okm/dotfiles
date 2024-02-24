return {
  "neovim/nvim-lspconfig",
  event = { "BUfReadPre" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  init = function()
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("PreWriteFormat", {}),
      callback = function()
        vim.lsp.buf.format({})
      end,
    })
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
      end,
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
        "eslint",
        "lua_ls",
        "tsserver",
      },
    })

    lspconfig.efm.setup({
      init_options = { documentFormatting = true },
    })

    local capabilities = cmp_nvim_lsp.default_capabilities()
    mlc.setup_handlers({
      ["eslint"] = function(server)
        lspconfig[server].setup({
          capabilities = capabilities,
          init_options = { documentFormatting = false, documentRangeFormatting = false },
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
          on_attach = function(_, _)
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("PreWriteEslintFix", {}),
              cmd = "EslintFixAll",
            })
          end,
        })
      end,
      ["tsserver"] = function(server)
        lspconfig[server].setup({
          capabilities = capabilities,
          init_options = { documentFormatting = false, documentRangeFormatting = false },
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        })
      end,
      ["lua_ls"] = function(server)
        lspconfig[server].setup({
          capabilities = capabilities,
          init_options = { documentFormatting = false, documentRangeFormatting = false },
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
          settings = { Lua = { diagnostics = { globals = { "vim" } } } },
        })
      end,
    })

    vim.diagnostic.config({
      virtual_text = true,
      severity_sort = true,
    })
  end,
}
