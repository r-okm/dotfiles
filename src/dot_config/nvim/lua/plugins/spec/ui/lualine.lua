return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("lualine").setup({
      options = {
        theme = "kanagawa",
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { { "branch", icon = "󰘬" }, "diff", "diagnostics" },
        lualine_c = { {
          "filename",
          path = 1,
        } },
        lualine_x = { "g:coc_status" },
        lualine_y = { "encoding", "filetype" },
        lualine_z = { "location" },
      },
    })
  end,
}
