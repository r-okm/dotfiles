local keymap = require("utils.setKeymap").keymap

return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    vim.cmd("set sessionoptions+=globals")
  end,
  config = function()
    keymap("n", "<C-l>", ":BufferLineCycleNext<CR>")
    keymap("n", "<C-h>", ":BufferLineCyclePrev<CR>")
    keymap("n", "L", ":BufferLineMoveNext<CR>")
    keymap("n", "H", ":BufferLineMovePrev<CR>")

    local bufferline = require("bufferline")
    bufferline.setup({
      options = {
        middle_mouse_command = "Bdelete %d",
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        show_buffer_close_icons = false,
      },
    })
  end,
}