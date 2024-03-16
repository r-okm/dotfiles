local keymap = require("utils.setKeymap").keymap

return {
  "akinsho/toggleterm.nvim",
  keys = {
    { "zg", mode = { "n" } },
  },
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
    })
    function LazygitToggle()
      lazygit:toggle()
    end
    keymap("n", "zg", "<cmd>lua LazygitToggle()<CR>")
  end,
}
