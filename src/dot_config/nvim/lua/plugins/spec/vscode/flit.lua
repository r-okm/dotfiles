return {
  "ggandor/flit.nvim",
  dependencies = { "ggandor/leap.nvim" },
  config = function()
    require("flit").setup({
      keys = { f = "f", F = "F", t = "t", T = "T" },
      labeled_modes = "nxo",
      multiline = false,
      opts = {
        safe_labels = {
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
        },
      },
    })
  end,
}
