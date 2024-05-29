return {
  "ggandor/leap.nvim",
  init = function()
    vim.keymap.set({ "n", "x", "o" }, "m", "<Plug>(leap)")
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
