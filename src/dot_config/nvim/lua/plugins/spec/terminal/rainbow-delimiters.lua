return {
  url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "BufReadPost" },
  config = function()
    require("rainbow-delimiters.setup").setup()
  end,
}
