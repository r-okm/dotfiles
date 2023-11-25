local keymap = require("utils.setKeymap").keymap

return {
  "rhysd/vim-operator-surround",
  dependencies = { "kana/vim-operator-user", "tpope/vim-repeat" },
  keys = {
    { "sa", mode = { "n", "x" } },
    { "sd", mode = { "n", "x" } },
    { "sr", mode = { "n", "x" } },
  },
  config = function()
    keymap("nx", "sa", "<Plug>(operator-surround-append)")
    keymap("n", "sd", "<Plug>(operator-surround-delete)a")
    keymap("n", "sr", "<Plug>(operator-surround-replace)a")
    keymap("x", "sd", "<Plug>(operator-surround-delete)")
    keymap("x", "sr", "<Plug>(operator-surround-replace)")
  end,
}
