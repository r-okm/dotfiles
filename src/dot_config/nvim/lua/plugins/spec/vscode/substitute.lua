local keymap = require("utils.setKeymap").keymap

return {
  "gbprod/substitute.nvim",
  keys = {
    { ",", mode = { "n", "x" } },
  },
  config = function()
    local substitute = require("substitute")
    substitute.setup({
      highlight_substituted_text = {
        enabled = false,
      },
    })
    keymap("nx", ",", function()
      substitute.operator()
    end)
  end,
}
