return {
  "windwp/nvim-ts-autotag",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-ts-autotag").setup({
      enable = true,
      enable_rename = true,
      enable_close = true,
      enable_close_on_slash = true,
    })
  end,
}
