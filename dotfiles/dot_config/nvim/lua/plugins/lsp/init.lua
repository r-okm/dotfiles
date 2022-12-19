return function(use)
  local not_vscode = function()
    return vim.g.vscode == nil
  end

  -- lsp
  use {
    'neovim/nvim-lspconfig',
    cond = not_vscode,
  }
  use {
    'williamboman/mason.nvim',
    config = require('plugins.lsp._mason'),
    cond = not_vscode,
  }
  use {
    'williamboman/mason-lspconfig.nvim',
    config = require('plugins.lsp._mason-lspconfig'),
    cond = not_vscode,
  }
  use {
    'jay-babu/mason-null-ls.nvim',
    config = require('plugins.lsp._mason-null-ls'),
    cond = not_vscode,
  }
  use {
    'jose-elias-alvarez/null-ls.nvim',
    config = require('plugins.lsp._null-ls'),
    cond = not_vscode,
  }
  use {
    'j-hui/fidget.nvim',
    config = require('plugins.lsp._fidget'),
    cond = not_vscode,
  }
  -- cmp
  use {
    'hrsh7th/nvim-cmp',
    config = require('plugins.lsp._nvim-cmp'),
    cond = not_vscode,
  }
  use {
    'hrsh7th/cmp-nvim-lsp',
    cond = not_vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
  use {
    'hrsh7th/vim-vsnip',
    cond = not_vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
  use {
    'hrsh7th/cmp-buffer',
    cond = not_vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
  use {
    'hrsh7th/cmp-path',
    cond = not_vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
  use {
    'hrsh7th/cmp-cmdline',
    cond = not_vscode,
    requires = { 'hrsh7th/nvim-cmp' }
  }
end
