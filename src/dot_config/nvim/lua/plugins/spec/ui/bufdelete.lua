local keymap = require("utils.setKeymap").keymap

return {
  "famiu/bufdelete.nvim",
  keys = {
    { "<Space>w", mode = { "n" } }
  },
  cmd = { "Bdelete", "Bwipeout" },
  config = function()
    keymap("n", "<Space>w", ":<C-u>Bdelete<CR>")
  end,
}
