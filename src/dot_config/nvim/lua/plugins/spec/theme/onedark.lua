return {
  "navarasu/onedark.nvim",
  cond = true,
  config = function()
    local onedark = require("onedark")
    local colors = require("onedark.palette").dark
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
        IblIndent = { fg = colors.bg2 },
      },
    })
    onedark.load()
  end,
}
