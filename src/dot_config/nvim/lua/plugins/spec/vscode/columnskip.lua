return {
  "tyru/columnskip.vim",
  init = function()
    vim.keymap.set({ "n", "x", "o" }, "gj", "<Plug>(columnskip:nonblank:next)")
    vim.keymap.set({ "n", "x", "o" }, "gk", "<Plug>(columnskip:nonblank:prev)")
  end,
}
