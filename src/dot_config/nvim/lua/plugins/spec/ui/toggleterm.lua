local keymap = require("utils.setKeymap").keymap

return {
  "akinsho/toggleterm.nvim",
  keys = {
    { "<C-k><C-g>", mode = { "n" } },
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

    keymap("n", "<C-k><C-g>", "<cmd>lua LazygitToggle()<CR>")
  end,
}
