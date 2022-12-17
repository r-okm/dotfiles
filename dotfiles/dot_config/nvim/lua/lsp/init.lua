-- 0. LSP Sever management
require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

local mlc = require('mason-lspconfig')
mlc.setup({
  ensure_installed = require('lsp.server_list')
})
mlc.setup_handlers({
  function(server)
    local setupOptions = require(string.format('lsp.%s', server))
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
      keymapBuf('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
      keymapBuf('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
      vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)'
    end

    require('lspconfig')[server].setup(setupOptions)
  end,
})

-- 2. build-in LSP function
-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)
vim.o.updatetime = 250
-- Reference highlight
vim.cmd [[
highlight LspReferenceText  cterm=underline ctermfg=0 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
augroup lsp_document_highlight
  autocmd!
  autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
  autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
augroup END
]]

-- 3. completion (hrsh7th/nvim-cmp)
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true },
  }),
  experimental = {
    ghost_text = true,
  },
})
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "path" },
    { name = "cmdline" },
  },
})
