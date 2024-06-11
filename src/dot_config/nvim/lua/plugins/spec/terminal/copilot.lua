local keymap = require("utils.setKeymap").keymap

return {
  "github/copilot.vim",
  cond = os.getenv("GITHUB_COPILOT_ENABLED") == "1",
  event = { "BufReadPost", "CmdlineEnter" },
  config = function()
    keymap("i", "<C-K>", "<Plug>(copilot-suggest)")
    keymap("i", "<C-N>", "<Plug>(copilot-next)")
    keymap("i", "<C-P>", "<Plug>(copilot-previous)")
    keymap("i", "<Tab>", "copilot#Accept('<Tab>')", {
      expr = true,
      replace_keycodes = false,
    })
  end,
}
