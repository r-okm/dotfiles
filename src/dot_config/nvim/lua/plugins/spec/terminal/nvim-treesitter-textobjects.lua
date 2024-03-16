return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  cond = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "BufReadPost" },
  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["ap"] = "@parameter.outer",
            ["ip"] = "@parameter.inner",
          },
          selection_modes = {
            ["@function.outer"] = "V",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<Space>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<Space>A"] = "@parameter.inner",
          },
        },
      },
    })
  end,
}
