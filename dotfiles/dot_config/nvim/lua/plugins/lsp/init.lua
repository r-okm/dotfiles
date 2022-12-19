return function(use)
  local _use = function(opts)
    opts.cond = function()
      return vim.g.vscode == nil
    end
    use(opts)
  end

  -- lsp
  _use {
    'neovim/nvim-lspconfig',
  }
  _use {
    'williamboman/mason.nvim',
    config = require('plugins.lsp._mason'),
  }
  _use {
    'williamboman/mason-lspconfig.nvim',
    config = require('plugins.lsp._mason-lspconfig'),
  }
  _use {
    'jay-babu/mason-null-ls.nvim',
    config = require('plugins.lsp._mason-null-ls'),
  }
  _use {
    'jose-elias-alvarez/null-ls.nvim',
    config = require('plugins.lsp._null-ls'),
  }
  _use {
    'j-hui/fidget.nvim',
    config = require('plugins.lsp._fidget'),
  }
  -- cmp
  _use {
    'hrsh7th/nvim-cmp',
    config = require('plugins.lsp._nvim-cmp'),
    requires = {
      { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp' },
      { 'hrsh7th/vim-vsnip', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
    }
  }

end
