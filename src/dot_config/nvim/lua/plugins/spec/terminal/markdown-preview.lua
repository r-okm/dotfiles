local keymap = require("utils.setKeymap").keymap

return {
  "iamcco/markdown-preview.nvim",
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  config = function()
    keymap("n", "<C-k><C-v>", ":<C-u>MarkdownPreviewToggle<CR>")
  end,
}
