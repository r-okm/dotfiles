return {
  "tyru/columnskip.vim",
  init = function()
    vim.keymap.set({ "n", "x", "o" }, "zj", "<Plug>(columnskip:nonblank:next)")
    vim.keymap.set({ "n", "x", "o" }, "zk", "<Plug>(columnskip:nonblank:prev)")
  end,
}
