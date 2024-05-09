local keymap = require("utils.setKeymap").keymap

return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "zh", mode = { "n" } },
    { "zh", mode = { "x" } },
    { "zl", mode = { "n" } },
  },
  cmd = { "DiffviewFileHistory" },
  config = function()
    keymap("n", "zh", ":<C-u>DiffviewFileHistory %<CR>")
    keymap("x", "zh", ":'<,'>DiffviewFileHistory<CR>")
    keymap("n", "zl", ":<C-u>DiffviewFileHistory<CR>")

    require("diffview").setup({
      keymaps = {
        view = {
          { "n", "q", ":<C-u>tabc<CR>" },
        },
        file_history_panel = {
          { "n", "q", ":<C-u>tabc<CR>" },
        },
      },
    })
  end,
}
