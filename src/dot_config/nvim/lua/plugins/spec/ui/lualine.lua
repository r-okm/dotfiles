return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin",
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch", icon = "󰘬" },
          "diff",
          { "diagnostics", sources = { "nvim_lsp", "nvim_diagnostic", "nvim_workspace_diagnostic" } },
        },
        lualine_c = { {
          "filename",
          path = 1,
        } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
