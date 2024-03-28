local const = require("utils.const")

return {
  "lukas-reineke/indent-blankline.nvim",
  dependenciess = {
    { url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim" },
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
  config = function()
    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }
    local hooks = require("ibl.hooks")
    -- create the highlight groups in the highlight setup hook, so they are reset
    -- every time the colorscheme changes
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    end)

    vim.g.rainbow_delimiters = { highlight = highlight }

    require("ibl").setup({
      indent = {
        char = "▏", -- :h ibl.config.indent.char
      },
      scope = {
        enabled = true,
        highlight = highlight,
      },
      exclude = {
        filetypes = const.HIGHLIGHT_DISABLED_FILETYPES,
      },
    })
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
  end,
}
