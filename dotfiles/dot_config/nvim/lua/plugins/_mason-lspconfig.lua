return function()
  local mlc = require('mason-lspconfig')

  mlc.setup({
    ensure_installed = require('lsp.server_list')
  })
  mlc.setup_handlers({
    function(server)
      -- server 固有の設定
      local opts = require(string.format('lsp._%s', server))

      -- 共通設定
      opts.capabilities = require('cmp_nvim_lsp').default_capabilities()
      opts.on_attach = function(client, bufnr)
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

        -- server 固有の on_attach ハンドラーを実行
        opts.on_attach_extra(client, bufnr)
      end

      -- setup
      require('lspconfig')[server].setup(opts)
    end,
  })

end
