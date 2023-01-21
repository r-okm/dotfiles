return function()
  require("workspaces").setup {
    hooks = {
      open = { "Ide" }
    }
  }
end
