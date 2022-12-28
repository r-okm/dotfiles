return function(use)
  use {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre" },
    cmd = { "Mason" },
    requires = {
      { "williamboman/mason.nvim", module = { "mason" } },
      { "williamboman/mason-lspconfig.nvim", module = { "mason-lspconfig" } },
      {
        "https://gitlab.com/yorickpeterse/nvim-dd.git",
        as = "nvim-dd",
        opt = true,
        config = require("plugins.lsp.nvim-dd.config")
      },
      { "jose-elias-alvarez/typescript.nvim", module = { "typescript" } },
      { "b0o/schemastore.nvim", module = { "schemastore" } },
      {
        "j-hui/fidget.nvim",
        module = { "fidget" },
        config = function()
          require("fidget").setup()
        end,
      },
      {
        "ray-x/lsp_signature.nvim",
        module = { "lsp_signature" },
        config = function()
          require("lsp_signature").setup({
            toggle_key = "<C-k>",
            hint_enable = false,
            handler_opts = {
              border = "single",
            },
          })
        end
      }
    },
    wants = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "nvim-dd",
      "typescript.nvim",
      "schemastore.nvim",
      "fidget.nvim",
      "lsp_signature.nvim",
      "mason-null-ls.nvim",
      "null-ls.nvim",
      "cmp-nvim-lsp",
    },
    cond = function()
      return not vim.g.vscode
    end,
    config = require("plugins.lsp.lspconfig.config"),
  }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre" },
    requires = {
      { "jay-babu/mason-null-ls.nvim", module = { "mason-null-ls" } },
    },
    wants = {
      "mason-null-ls.nvim",
    },
    cond = function()
      return not vim.g.vscode
    end,
    config = require("plugins.lsp.null-ls.config"),
  }
end
