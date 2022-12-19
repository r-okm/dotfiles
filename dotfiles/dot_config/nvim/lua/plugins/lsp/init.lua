return function(use)
  -- lsp
  use { 'neovim/nvim-lspconfig' }
  use {
    'williamboman/mason.nvim',
    config = require('plugins.lsp._mason'),
  }
  use {
    'williamboman/mason-lspconfig.nvim',
    config = require('plugins.lsp._mason-lspconfig'),
  }
  use {
    'jay-babu/mason-null-ls.nvim',
    config = require('plugins.lsp._mason-null-ls')
  }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    config = require('plugins.lsp._null-ls')
  }
  use {
    'j-hui/fidget.nvim',
    config = require('plugins.lsp._fidget')
  }
  -- cmp
  use {
    'hrsh7th/nvim-cmp',
    config = require('plugins.lsp._nvim-cmp'),
  }
  use { 'hrsh7th/cmp-nvim-lsp' }
  use { 'hrsh7th/vim-vsnip' }
  use { 'hrsh7th/cmp-buffer' }
  use { 'hrsh7th/cmp-path' }
  use { 'hrsh7th/cmp-cmdline' }
end
