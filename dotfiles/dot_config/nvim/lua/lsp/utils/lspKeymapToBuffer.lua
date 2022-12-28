return function(bufnr)
  local keymap = require("utils.setKeymap").keymap
  local tb = require("telescope.builtin")

  local ref      = tb.lsp_references
  local def      = tb.lsp_definitions
  local type_def = tb.lsp_type_definitions
  local impl     = tb.lsp_implementations
  local diag     = tb.diagnostics

  local bufnew = { jump_type = "vsplit" }

  keymap("n", "K", function() vim.lsp.buf.hover() end, { buffer = bufnr })
  keymap("n", "gf", function() vim.lsp.buf.format() end, { buffer = bufnr })
  keymap("n", "gd", function() def() end, { buffer = bufnr })
  keymap("n", "gD", function() def(bufnew) end, { buffer = bufnr })
  keymap("n", "gt", function() type_def() end, { buffer = bufnr })
  keymap("n", "gT", function() type_def(bufnew) end, { buffer = bufnr })
  keymap("n", "go", function() ref() end, { buffer = bufnr })
  keymap("n", "gi", function() impl() end, { buffer = bufnr })
  keymap("n", "gI", function() impl(bufnew) end, { buffer = bufnr })
  keymap("n", "gr", function() vim.lsp.buf.rename() end, { buffer = bufnr })
  keymap("nv", "ga", require("actions-preview").code_actions, { buffer = bufnr })
  keymap("n", "gw", function() diag({ bufnr = 0 }) end, { buffer = bufnr })
  keymap("n", "gW", function() diag({ bufnr = nil }) end, { buffer = bufnr })
  keymap("n", "ge", function() vim.diagnostic.open_float() end, { buffer = bufnr })
  keymap("n", "g.", function() vim.diagnostic.goto_next() end, { buffer = bufnr })
  keymap("n", "g,", function() vim.diagnostic.goto_prev() end, { buffer = bufnr })
end
