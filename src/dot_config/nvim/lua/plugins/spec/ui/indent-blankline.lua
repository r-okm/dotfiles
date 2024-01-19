local const = require("utils.const")

return {
  "lukas-reineke/indent-blankline.nvim",
  dependencies = {
    "TheGLander/indent-rainbowline.nvim",
  },
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
  opts = function()
    local ibl_opts = {
      indent = {
        char = "▏",
      },
      scope = {
        enabled = false,
      },
      exclude = {
        filetypes = const.HIGHLIGHT_DISABLED_FILETYPES,
      },
    }
    local irl_opts = {
      color_transparency = 0.06,
    }
    return require("indent-rainbowline").make_opts(ibl_opts, irl_opts)
  end,
}
