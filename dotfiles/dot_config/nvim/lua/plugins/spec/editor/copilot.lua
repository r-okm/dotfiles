local keymap = require("utils.setKeymap").keymap

return {
  "github/copilot.vim",
  event = { "InsertEnter", "CmdlineEnter" },
  config = function()
    keymap("i", "<Tab>", "copilot#Accept('<Tab>')", {
      expr = true,
      replace_keycodes = false
    })
  end
}
