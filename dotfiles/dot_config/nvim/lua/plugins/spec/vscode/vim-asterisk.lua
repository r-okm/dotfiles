local keymap = require("utils.setKeymap").keymap

return {
  "haya14busa/vim-asterisk",
  keys = {
    { "*", mode = { "n", "x" } },
  },
  config = function()
    keymap("nx", "*", "<Plug>(asterisk-gz*)")
  end,
}
