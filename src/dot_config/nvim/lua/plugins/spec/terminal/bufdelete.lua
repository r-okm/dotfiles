return {
  "famiu/bufdelete.nvim",
  keys = {
    { "<Space>w", mode = { "n" } },
  },
  cmd = { "Bdelete", "Bwipeout" },
  config = function()
    vim.keymap.set("n", "<Space>w", ":<C-u>Bdelete<CR>", { noremap = true, silent = true })
  end,
}
