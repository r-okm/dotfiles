return function(bufnr, fmtServerName)
  local keymap = require("utils.setKeymap").keymap
  local tb = require("telescope.builtin")

  local lsp_formatting = function()
    vim.lsp.buf.format({
      bufnr = bufnr,
      filter = function(client)
        return client.name == fmtServerName
      end
    })
  end

  local keymapToBuffer = function(modeStr, lhs, rhs)
    keymap(modeStr, lhs, rhs, { buffer = bufnr })
  end

  local M = {}
  M.setActionsKey = function()
    keymapToBuffer("n", "K", "<cmd>Lspsaga hover_doc<CR>")
    keymapToBuffer("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
    keymapToBuffer("n", "gD", function() tb.lsp_references() end)
    keymapToBuffer("n", "gr", "<cmd>Lspsaga rename<CR>")
    keymapToBuffer("nv", "ga", "<cmd>Lspsaga code_action<CR>")
    keymapToBuffer("n", "gw", function() tb.diagnostics({ bufnr = 0 }) end)
    keymapToBuffer("n", "gW", function() tb.diagnostics({ bufnr = nil }) end)
    keymapToBuffer("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
    keymapToBuffer("n", "g.", "<cmd>Lspsaga diagnostic_jump_next<CR>")
    keymapToBuffer("n", "g,", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
  end
  M.setFmtKey = function()
    keymapToBuffer("n", "gf", lsp_formatting)
  end
  M.setFmtOnSave = function()
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = lsp_formatting,
    })
  end

  return M
end
