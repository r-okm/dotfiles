return function(use)
  local conf = require('plugins.lsp.conf')
  local not_vscode = function()
    return vim.g.vscode == nil
  end

  use {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre' },
    cond = not_vscode(),
    requires = {
      { 'williamboman/mason.nvim', module = { 'mason' } },
      { 'williamboman/mason-lspconfig.nvim', module = { 'mason-lspconfig' } },
      { 'jose-elias-alvarez/typescript.nvim', module = { 'typescript' } },
    },
    wants = {
      'mason.nvim',
      'mason-lspconfig.nvim',
      'typescript.nvim',
      'mason-null-ls.nvim',
      'null-ls.nvim',
      'cmp-nvim-lsp',
    },
    config = conf.lspconfig.config,
  }

  use {
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPre' },
    cond = not_vscode(),
    requires = {
      { 'jay-babu/mason-null-ls.nvim', module = { 'mason-null-ls' } },
    },
    wants = {
      'mason-null-ls.nvim',
    },
    config = conf.null_ls.config,
  }

  use {
    'j-hui/fidget.nvim',
    event = { 'BufReadPre' },
    cond = not_vscode(),
    config = conf.fidget.config
  }
end
