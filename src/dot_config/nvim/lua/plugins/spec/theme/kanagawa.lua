return {
  "rebelot/kanagawa.nvim",
  cond = false,
  config = function()
    require("kanagawa").setup({
      commentStyle = { italic = false },
      keywordStyle = { italic = false },
      variablebuiltinStyle = { italic = false },
    })
    vim.cmd([[colorscheme kanagawa]])
  end,
}
