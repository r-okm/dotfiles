return function(use)
  -- cmp
  use {
    'hrsh7th/nvim-cmp',
    module = 'cmp',
    requires = {
      { 'hrsh7th/cmp-nvim-lsp', event = { 'InsertEnter' } },
      { 'hrsh7th/vim-vsnip', event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-buffer', event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-path', event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-cmdline', event = { 'InsertEnter', 'CmdlineEnter' } },
    },
    cond = function()
      return not vim.g.vscode
    end,
    config = require('plugins.completion._nvim-cmp'),
  }

end
