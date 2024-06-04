return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local gs = require("gitsigns")

    gs.setup({
      current_line_blame_opts = {
        delay = 500,
      },
    })
    vim.keymap.set("n", "zn", gs.toggle_current_line_blame, { noremap = true, silent = true })
  end,
}
