return function(use)
  local conf = require('plugins.lsp.conf')

  use {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre' },
    cmd = { "Mason" },
    requires = {
      { 'williamboman/mason.nvim', module = { 'mason' } },
      { 'williamboman/mason-lspconfig.nvim', module = { 'mason-lspconfig' } },
      {
        "https://gitlab.com/yorickpeterse/nvim-dd.git",
        as = "nvim-dd",
        opt = true,
        config = require("plugins.lsp.nvim-dd.config")
      },
      { 'jose-elias-alvarez/typescript.nvim', module = { 'typescript' } },
      { 'b0o/schemastore.nvim', module = { 'schemastore' } },
    },
    wants = {
      'mason.nvim',
      'mason-lspconfig.nvim',
      "nvim-dd",
      'typescript.nvim',
      'schemastore.nvim',
      'mason-null-ls.nvim',
      'null-ls.nvim',
      'cmp-nvim-lsp',
    },
    cond = function()
      return not vim.g.vscode
    end,
    config = conf.lspconfig.config,
  }

  use {
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPre' },
    requires = {
      { 'jay-babu/mason-null-ls.nvim', module = { 'mason-null-ls' } },
    },
    wants = {
      'mason-null-ls.nvim',
    },
    cond = function()
      return not vim.g.vscode
    end,
    config = conf.null_ls.config,
  }

  use {
    'j-hui/fidget.nvim',
    event = { 'BufReadPre' },
    cond = function()
      return not vim.g.vscode
    end,
    config = conf.fidget.config,
  }
end
