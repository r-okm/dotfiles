return function(use)
  -- lsp
  use {
    'neovim/nvim-lspconfig',
  }
  use {
    'williamboman/mason.nvim',
    config = require('plugins.lsp._mason'),
    after = { 'nvim-lspconfig' },
  }
  use {
    'williamboman/mason-lspconfig.nvim',
    config = require('plugins.lsp._mason-lspconfig'),
    after = { 'nvim-lspconfig', 'mason.nvim', 'cmp-nvim-lsp' },
  }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    config = require('plugins.lsp._null-ls'),
    after = { 'mason.nvim' },
  }
  use {
    'jay-babu/mason-null-ls.nvim',
    config = require('plugins.lsp._mason-null-ls'),
    after = { 'nvim-lspconfig', 'mason.nvim', 'null-ls.nvim' },
  }
  use {
    'j-hui/fidget.nvim',
    config = require('plugins.lsp._fidget'),
  }

end
