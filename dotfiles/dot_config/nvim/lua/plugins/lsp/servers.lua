local M = {}

M.list = {
  lsp = {
    'eslint',
    'sumneko_lua',
    'tsserver',
  },
  null_ls = {
    'prettierd',
  },
}

M.configs = {
  eslint = {},

  sumneko_lua = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        },
      },
    },
  },

  tsserver = {},
}

M.attach_handlers = {
  common = function(_, bufnr)
    local keymap = require('utils.setKeymap').keymap

    keymap('n', 'K', function() vim.lsp.buf.hover() end, { buffer = bufnr })
    keymap('n', 'gf', function() vim.lsp.buf.format() end, { buffer = bufnr })
    keymap('n', 'gr', function() vim.lsp.buf.references() end, { buffer = bufnr })
    keymap('n', 'gd', function()
      require('telescope.builtin').lsp_definitions({ jump_type = 'vsplit' })
    end, { buffer = bufnr })
    keymap('n', 'gD', function() vim.lsp.buf.definition() end, { buffer = bufnr })
    keymap('n', 'gi', function() vim.lsp.buf.implementation() end, { buffer = bufnr })
    keymap('n', 'gt', function() vim.lsp.buf.type_definition() end, { buffer = bufnr })
    keymap('n', 'gn', function() vim.lsp.buf.rename() end, { buffer = bufnr })
    keymap('n', 'ga', function() vim.lsp.buf.code_action() end, { buffer = bufnr })
    keymap('n', 'ge', function() vim.diagnostic.open_float() end, { buffer = bufnr })
    keymap('n', 'g.', function() vim.diagnostic.goto_next() end, { buffer = bufnr })
    keymap('n', 'g,', function() vim.diagnostic.goto_prev() end, { buffer = bufnr })
  end,

  eslint = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'EslintFixAll',
      desc = "[lsp] eslint fix all on save",
    })
  end,

  sumneko_lua = function(_, bufnr)
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
      desc = "[lsp] format on save",
    })
  end,

  tsserver = function(client, _)
    client.server_capabilities.documentFormattingProvider = false
  end,
}

return M
