return {
  "j-hui/fidget.nvim",
  init = function()
    require("fidget").setup({
      progress = {
        ignore = { "null-ls" },
      },
    })
  end,
}
