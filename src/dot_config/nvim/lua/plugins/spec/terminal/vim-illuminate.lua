local const = require("utils.const")

return {
  "RRethy/vim-illuminate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("illuminate").configure({
      filetypes_denylist = const.HIGHLIGHT_DISABLED_FILETYPES,
      large_file_cutoff = 1000,
    })
  end,
}
