-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local tb = require("telescope.builtin")

    -- Buffer local mappings.
    local opts = { buffer = ev.buf }

    -- diagnostic
    vim.keymap.set("n", "g.", "<cmd>Lspsaga diagnostic_jump_next<CR>")
    vim.keymap.set("n", "g,", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
    vim.keymap.set("n", "gw", function()
      tb.diagnostics({ bufnr = 0 })
    end)
    vim.keymap.set("n", "gW", function()
      tb.diagnostics({ bufnr = nil })
    end)
    vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
    -- code navigation
    vim.keymap.set("n", "gd", function()
      tb.lsp_definitions()
    end, opts)
    vim.keymap.set("n", "gD", function()
      tb.lsp_implementations()
    end, opts)
    vim.keymap.set("n", "gt", function()
      tb.lsp_type_definitions()
    end, opts)
    vim.keymap.set("n", "grr", function()
      tb.lsp_references()
    end, opts)
    -- hover code action
    vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
    -- symbol rename
    vim.keymap.set("n", "grn", "<cmd>Lspsaga rename<CR>", opts)
    -- format
    vim.keymap.set("n", "gf", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    -- code action
    vim.keymap.set({ "n", "v" }, "ga", "<cmd>Lspsaga code_action<CR>", opts)

    -- setup diagnostic signs
    local signs = {
      Error = " ",
      Warn = " ",
      Info = " ",
      Hint = " ",
    }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    local function diagnostic_formatter(diagnostic)
      return string.format("[%s] %s (%s)", diagnostic.message, diagnostic.source, diagnostic.code)
    end
    vim.diagnostic.config({
      virtual_text = false,
      severity_sort = true,
      underline = true,
      signs = true,
      update_in_insert = false,
      float = { format = diagnostic_formatter },
    })
  end,
})

-- insert モードを抜けたときに IME を OFF
if vim.fn.executable("zenhan.exe") then
  vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, { command = "call system('zenhan.exe 0')" })
end

-- terminal モードで nonumber
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(_)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
