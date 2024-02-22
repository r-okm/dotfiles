return {
  "navarasu/onedark.nvim",
  cond = false,
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
        IlluminatedWordText = { bg = colors.bg3, fmt = "NONE" },
        IlluminatedWordRead = { bg = colors.bg3, fmt = "NONE" },
        IlluminatedWordWrite = { bg = colors.bg3, fmt = "NONE" },
      },
    })
    onedark.load()
  end,
}
