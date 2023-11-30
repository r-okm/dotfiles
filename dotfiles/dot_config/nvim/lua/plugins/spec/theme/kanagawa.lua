return {
  "rebelot/kanagawa.nvim",
  cond = true,
  config = function()
    require("kanagawa").setup({
      commentStyle = { italic = false },
      keywordStyle = { italic = false },
      variablebuiltinStyle = { italic = false },
    })
    vim.cmd([[colorscheme kanagawa]])
  end,
}
