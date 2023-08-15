return function(use)
  use {
    "ellisonleao/gruvbox.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    event = "BufEnter",
    config = function()
      vim.o.background = "dark"
      vim.cmd([[colorscheme gruvbox]])
    end,
  }
end
