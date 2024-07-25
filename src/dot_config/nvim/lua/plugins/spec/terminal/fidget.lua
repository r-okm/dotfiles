return {
  "j-hui/fidget.nvim",
  init = function()
    require("fidget").setup({
      progress = {
        ignore = { "null-ls" },
      },
      notification = {
        window = {
          winblend = 0,
        },
      },
    })
  end,
}
