local const = require("utils.const")

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    function DisableIblCurrentBuf()
      require("ibl").setup_buffer(0, { enabled = false })
    end
    function EnableIblCurrentBuf()
      require("ibl").setup_buffer(0, { enabled = true })
    end
  end,
  opts = {
    indent = {
      char = "▏",
    },
    scope = {
      enabled = false,
    },
    exclude = {
      filetypes = const.HIGHLIGHT_DISABLED_FILETYPES,
    },
  },
}
