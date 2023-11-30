local keymap = require("utils.setKeymap").keymap

return {
  "ggandor/leap.nvim",
  keys = {
    { "m", mode = { "n", "x", "o" } },
  },
  config = function()
    local leap = require("leap")
    leap.opts.safe_labels = {}
    leap.opts.labels = {
      "s", "f", "n",
      "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
      "u", "y", "v", "r", "g", "t", "c", "x", "/", "z"
    }
    keymap("nxo", "m", function()
      leap.leap { target_windows = { vim.fn.win_getid() } }
    end)
  end,
}
