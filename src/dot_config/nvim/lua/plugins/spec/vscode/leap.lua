return {
  "ggandor/leap.nvim",
  init = function()
    local keymap = require("utils.setKeymap").keymap
    keymap("nxo", "m", "<Plug>(leap-forward)")
    keymap("nxo", "M", "<Plug>(leap-backward)")
  end,
  config = function()
    local leap = require("leap")
    leap.opts.safe_labels = {}
    leap.opts.labels = {
      "s",
      "f",
      "n",
      "j",
      "k",
      "l",
      "h",
      "o",
      "d",
      "w",
      "e",
      "m",
      "b",
      "u",
      "y",
      "v",
      "r",
      "g",
      "t",
      "c",
      "x",
      "/",
      "z",
    }
  end,
}
