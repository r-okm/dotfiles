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
    local function map(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr })
    end

    map('n', 'K', function() vim.lsp.buf.hover() end)
    map('n', 'gf', function() vim.lsp.buf.format() end)
    map('n', 'gr', function() vim.lsp.buf.references() end)
    map('n', 'gd', function() vim.lsp.buf.definition() end)
    map('n', 'gD', function() vim.lsp.buf.declaration() end)
    map('n', 'gi', function() vim.lsp.buf.implementation() end)
    map('n', 'gt', function() vim.lsp.buf.type_definition() end)
    map('n', 'gn', function() vim.lsp.buf.rename() end)
    map('n', 'ga', function() vim.lsp.buf.code_action() end)
    map('n', 'ge', function() vim.diagnostic.open_float() end)
    map('n', 'g.', function() vim.diagnostic.goto_next() end)
    map('n', 'g,', function() vim.diagnostic.goto_prev() end)
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
