return function(use)
  local vscode = not vim.g.vscode

  -- lsp
  use {
    'neovim/nvim-lspconfig',
    cond = vscode,
  }
  use {
    'williamboman/mason.nvim',
    config = require('plugins.lsp._mason'),
    cond = vscode,
  }
  use {
    'williamboman/mason-lspconfig.nvim',
    config = require('plugins.lsp._mason-lspconfig'),
    cond = vscode,
  }
  use {
    'jay-babu/mason-null-ls.nvim',
    config = require('plugins.lsp._mason-null-ls'),
    cond = vscode,
  }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    config = require('plugins.lsp._null-ls'),
    cond = vscode,
  }
  use {
    'j-hui/fidget.nvim',
    config = require('plugins.lsp._fidget'),
    cond = vscode,
  }
  -- cmp
  use {
    'hrsh7th/nvim-cmp',
    config = require('plugins.lsp._nvim-cmp'),
    cond = vscode,
  }
  use {
    'hrsh7th/cmp-nvim-lsp',
    cond = vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
  use {
    'hrsh7th/vim-vsnip',
    cond = vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
  use {
    'hrsh7th/cmp-buffer',
    cond = vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
  use {
    'hrsh7th/cmp-path',
    cond = vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
  use {
    'hrsh7th/cmp-cmdline',
    cond = vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
end
