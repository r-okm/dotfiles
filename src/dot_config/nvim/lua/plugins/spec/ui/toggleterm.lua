local keymap = require("utils.setKeymap").keymap

return {
  "akinsho/toggleterm.nvim",
  keys = {
    { "zg", mode = { "n" } },
    { "zl", mode = { "n" } },
  },
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
    })
    local gitLog = Terminal:new({
      cmd = "git lga",
      direction = "float",
      hidden = true,
    })

    function LazygitToggle()
      lazygit:toggle()
    end
    function GitLogToggle()
      gitLog:toggle()
    end

    keymap("n", "zg", "<cmd>lua LazygitToggle()<CR>")
    keymap("n", "zl", "<cmd>lua GitLogToggle()<CR>")
  end,
}
