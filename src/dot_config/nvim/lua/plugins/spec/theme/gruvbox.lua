return {
  "ellisonleao/gruvbox.nvim",
  cond = false,
  config = function()
    require("gruvbox").setup({
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
    })
    vim.cmd([[colorscheme gruvbox]])
  end,
}
