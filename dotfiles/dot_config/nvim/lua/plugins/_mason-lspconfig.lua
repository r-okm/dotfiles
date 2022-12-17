return function()
  local mlc = require('mason-lspconfig')

  mlc.setup({
    ensure_installed = require('lsp.server_list')
  })
  mlc.setup_handlers({
    function(server)
      -- server 固有の設定
      local setupOptions = require(string.format('lsp.%s', server))

      -- 共通設定
      setupOptions.capabilities = require('cmp_nvim_lsp').default_capabilities()
      setupOptions.on_attach = function(_, bufnr)
        local opts = { noremap = true, silent = true }
        local function keymapBuf(mode, lhs, rhs)
          vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
        end

        keymapBuf('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
        keymapBuf('n', 'gf', '<cmd>lua vim.lsp.buf.format()<CR>')
        keymapBuf('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
        keymapBuf('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
        keymapBuf('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
        keymapBuf('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
        keymapBuf('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
        keymapBuf('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
        keymapBuf('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
        keymapBuf('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
        keymapBuf('n', 'g.', '<cmd>lua vim.diagnostic.goto_next()<CR>')
        keymapBuf('n', 'g,', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
        vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)'
      end

      -- setup
      require('lspconfig')[server].setup(setupOptions)
    end,
  })

end
