return {
  "windwp/nvim-ts-autotag",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      },
    })
  end,
}
