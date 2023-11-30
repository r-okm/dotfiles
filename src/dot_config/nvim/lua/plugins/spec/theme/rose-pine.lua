return {
  "rose-pine/neovim",
  name = "rose-pine",
  cond = false,
  config = function()
    require("rose-pine").setup({
      variant = "main",
      disable_italics = true,
    })
    vim.cmd([[colorscheme rose-pine]])
  end,
}
