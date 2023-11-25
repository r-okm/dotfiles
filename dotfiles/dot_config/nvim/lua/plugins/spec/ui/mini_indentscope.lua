return {
  "echasnovski/mini.indentscope",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local mi = require("mini.indentscope")
    mi.setup({
      delay = 1,
      animation = mi.gen_animation.none(),
      symbol = "▏",
    })
  end,
}
