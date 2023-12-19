local keymap = require("utils.setKeymap").keymap

return {
  "kevinhwang91/nvim-hlslens",
  dependencies = { "haya14busa/vim-asterisk" },
  keys = {
    { "*", mode = { "n", "x" } },
    { "n", mode = { "n" } },
    { "N", mode = { "n" } },
  },
  config = function()
    keymap("nx", "*", [[<Plug>(asterisk-gz*)<Cmd>lua require("hlslens").start()<CR>]])
    keymap("n", "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]])
    keymap("n", "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]])
    require("scrollbar.handlers.search").setup({
      calm_down = true,
      nearest_only = true,
      nearest_float_when = "never",
    })
  end,
}
