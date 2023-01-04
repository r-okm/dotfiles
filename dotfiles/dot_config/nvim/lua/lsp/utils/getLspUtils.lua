local keymap = require("utils.setKeymap").keymap
local diag = require("telescope.builtin").diagnostics

return function(bufnr, fmtServerName)
  local lsp_formatting = function()
    vim.lsp.buf.format({
      bufnr = bufnr,
      filter = function(client)
        return client.name == fmtServerName
      end
    })
  end

  local M = {}
  M.setActionsKey = function()
    keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { buffer = bufnr })
    keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { buffer = bufnr })
    keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { buffer = bufnr })
    keymap("nv", "ga", "<cmd>Lspsaga code_action<CR>", { buffer = bufnr })
    keymap("n", "gw", function() diag({ bufnr = 0 }) end, { buffer = bufnr })
    keymap("n", "gW", function() diag({ bufnr = nil }) end, { buffer = bufnr })
    keymap("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>", { buffer = bufnr })
    keymap("n", "g.", "<cmd>Lspsaga diagnostic_jump_next<CR>", { buffer = bufnr })
    keymap("n", "g,", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { buffer = bufnr })
  end
  M.setFmtKey = function()
    keymap("n", "gf", lsp_formatting, { buffer = bufnr })
  end
  M.setFmtOnSave = function()
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = lsp_formatting,
    })
  end

  return M
end
