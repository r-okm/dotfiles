return function()
  require("workspaces").setup {
    hooks = {
      open = { "Trouble", "NvimTreeOpen" }
    }
  }
end
