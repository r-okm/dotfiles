return {
  "nvimdev/lspsaga.nvim",
  cmd = { "Lspsaga" },
  config = function()
    require("lspsaga").setup({
      breadcrumbs = { enable = false },
      lightbulb = { enable = false },
      rename = { in_select = false },
      ui = { border = "single" },
    })
  end,
}
