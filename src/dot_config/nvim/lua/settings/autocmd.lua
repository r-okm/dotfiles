-- LSP
local lsp_configs = {
  -- vtsls と null-ls は別で設定するため未記載
  ["bashls"] = {
    format_cmd_enable = true,
    format_on_save = false,
  },
  ["lemminx"] = {
    format_cmd_enable = true,
    format_on_save = false,
  },
  ["rust_analyzer"] = {
    format_cmd_enable = true,
    format_on_save = true,
  },
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local tb = require("telescope.builtin")

    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    local format_cmd_enable = false
    local format_on_save = false
    for lsp, config in pairs(lsp_configs) do
      if client.name == lsp then
        format_cmd_enable = config.format_cmd_enable
        format_on_save = config.format_on_save
        break
      end
    end

    -- set keymap to current buffer
    local set_buf_key = function(modes, lhs, rhs)
      vim.keymap.set(modes, lhs, rhs, { buffer = bufnr })
    end

    -- diagnostic
    set_buf_key("n", "g.", "<cmd>Lspsaga diagnostic_jump_next<CR>")
    set_buf_key("n", "g,", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
    set_buf_key("n", "gw", function()
      tb.diagnostics({ bufnr = 0 })
    end)
    set_buf_key("n", "gW", function()
      tb.diagnostics({ bufnr = nil })
    end)
    -- code navigation
    set_buf_key("n", "gd", function()
      tb.lsp_definitions()
    end)
    set_buf_key("n", "gD", function()
      tb.lsp_implementations()
    end)
    set_buf_key("n", "gt", function()
      tb.lsp_type_definitions()
    end)
    set_buf_key("n", "grr", function()
      tb.lsp_references()
    end)
    -- hover document
    if client.supports_method("textDocument/hover") then
      set_buf_key("n", "K", "<cmd>Lspsaga hover_doc<CR>")
    end
    -- symbol rename
    set_buf_key("n", "grn", "<cmd>Lspsaga rename<CR>")
    -- code action
    set_buf_key({ "n", "v" }, "ga", "<cmd>Lspsaga code_action<CR>")
    -- format
    if format_cmd_enable then
      set_buf_key("n", "gf", function()
        vim.lsp.buf.format({
          async = true,
          bufnr = bufnr,
          filter = function(format_client)
            return format_client.name == client.name
          end,
        })
      end)
    end
    if format_on_save then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("PreWrite" .. client.name .. bufnr, {}),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            async = false,
            bufnr = bufnr,
            filter = function(format_client)
              return format_client.name == client.name
            end,
          })
        end,
      })
    end

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

-- terminal モードで nonumber
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(_)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "yes"
  end,
})
