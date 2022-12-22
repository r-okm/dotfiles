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
    local tb = require('telescope.builtin')

    local ref      = tb.lsp_references
    local def      = tb.lsp_definitions
    local type_def = tb.lsp_type_definitions
    local impl     = tb.lsp_implementations
    local diag     = tb.diagnostics

    local bufnew = { jump_type = 'vsplit' }

    keymap('n', 'K', function() vim.lsp.buf.hover() end, { buffer = bufnr })
    keymap('n', 'gf', function() vim.lsp.buf.format() end, { buffer = bufnr })
    keymap('n', 'gm', function() def() end, { buffer = bufnr })
    keymap('n', 'gM', function() def(bufnew) end, { buffer = bufnr })
    keymap('n', 'gn', function() type_def() end, { buffer = bufnr })
    keymap('n', 'gN', function() type_def(bufnew) end, { buffer = bufnr })
    keymap('n', 'go', function() ref() end, { buffer = bufnr })
    keymap('n', 'gi', function() impl() end, { buffer = bufnr })
    keymap('n', 'gI', function() impl(bufnew) end, { buffer = bufnr })
    keymap('n', 'gr', function() vim.lsp.buf.rename() end, { buffer = bufnr })
    keymap('nv', 'ga', require('actions-preview').code_actions, { buffer = bufnr })
    keymap('n', 'gw', function() diag({ bufnr = 0 }) end, { buffer = bufnr })
    keymap('n', 'gW', function() diag({ bufnr = nil }) end, { buffer = bufnr })
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

  tsserver = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false

    local ts = require('typescript').actions
    local keymap = require('utils.setKeymap').keymap
    keymap('n', 'za', function() ts.addMissingImports({ sync = true }) end, { buffer = bufnr })
    keymap('n', 'zu', function() ts.removeUnused({ sync = true }) end, { buffer = bufnr })
    keymap('n', 'zo', function() ts.organizeImports({ sync = true }) end, { buffer = bufnr })

    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function()
        ts.fixAll({ sync = true })
      end,
      desc = "[lsp] typescript fix all on save",
    })
  end,
}

return M
