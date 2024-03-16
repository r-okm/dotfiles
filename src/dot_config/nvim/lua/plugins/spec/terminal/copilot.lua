local keymap = require("utils.setKeymap").keymap

return {
  "github/copilot.vim",
  event = { "BufReadPost", "CmdlineEnter" },
  config = function()
    vim.g.copilot_filetypes = { gitcommit = true }
    keymap("i", "<C-K>", "<Plug>(copilot-suggest)")
    keymap("i", "<C-N>", "<Plug>(copilot-next)")
    keymap("i", "<C-P>", "<Plug>(copilot-previous)")
    keymap("i", "<Tab>", "copilot#Accept('<Tab>')", {
      expr = true,
      replace_keycodes = false,
    })
  end,
}
