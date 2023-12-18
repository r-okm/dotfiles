return {
  "navarasu/onedark.nvim",
  cond = true,
  config = function()
    local onedark = require("onedark")
    onedark.setup({
      style = "dark",
      code_style = {
        comments = "none",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },
      highlights = {
        IblIndent = { fg = "#3d5566" },
      },
    })
    onedark.load()
  end,
}
