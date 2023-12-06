local keymap = require("utils.setKeymap").keymap

return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "zh", mode = { "n" } },
  },
  cmd = { "DiffviewFileHistory" },
  config = function()
    keymap("n", "zh", ":<C-u>DiffviewFileHistory %<CR>")
  end,
}
