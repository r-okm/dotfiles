return function()
  local keymap = require("utils.setKeymap").keymap
  keymap("n", "<C-l>", ":BufferLineCycleNext<CR>")
  keymap("n", "<C-h>", ":BufferLineCyclePrev<CR>")
  keymap("n", "L", ":BufferLineMoveNext<CR>")
  keymap("n", "H", ":BufferLineMovePrev<CR>")

  require("bufferline").setup({
    options = {
      middle_mouse_command = "Bdelete %d",
      diagnostics = "nvim_lsp",
      separator_style = "slant",
      offsets = {
        {
          filetype = "NvimTree",
          text = function()
            return vim.fn.getcwd()
          end,
          text_align = "left",
          separator = true,
        }
      },
      show_buffer_close_icons = false,
    }
  })
end
