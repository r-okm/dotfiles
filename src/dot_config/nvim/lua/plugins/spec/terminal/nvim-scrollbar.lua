return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost",
  config = function()
    require("scrollbar").setup({
      handle = {
        text = "  ",
        blend = 0,
      },
      marks = {
        Cursor = {
          text = "  ",
        },
        Search = {
          text = { "--", "==" },
          highlight = "HlSearchLens",
        },
        Error = {
          text = { "--", "==" },
        },
        Warn = {
          text = { "--", "==" },
        },
        Info = {
          text = { "--", "==" },
        },
        Hint = {
          text = { "--", "==" },
        },
        Misc = {
          text = { "--", "==" },
        },
      },
    })
  end,
}
