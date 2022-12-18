-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)
vim.o.updatetime = 250
-- Reference highlight
vim.cmd [[
highlight LspReferenceText cterm=underline ctermbg=8 gui=underline guibg=#104040
highlight LspReferenceRead cterm=underline ctermbg=8 gui=underline guibg=#104040
highlight LspReferenceWrite cterm=underline ctermbg=8 gui=underline guibg=#104040
augroup lsp_document_highlight
  autocmd!
  autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
  autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
augroup END
]]
