local keymap = require("utils.setKeymap").keymap

return {
  "romgrk/barbar.nvim",
  version = "^1.0.0",
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    vim.g.barbar_auto_setup = false
    vim.opt.sessionoptions:append("globals")
    vim.api.nvim_create_user_command("Mksession", function(attr)
      vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
      vim.cmd.mksession({ bang = attr.bang, args = attr.fargs })
    end, { bang = true, complete = "file", desc = "Save barbar with :mksession", nargs = "?" })
  end,
  config = function()
    keymap("n", "<C-l>", "<Cmd>BufferNext<CR>")
    keymap("n", "<C-h>", "<Cmd>BufferPrevious<CR>")
    keymap("n", "L", "<Cmd>BufferMoveNext<CR>")
    keymap("n", "H", "<Cmd>BufferMovePrevious<CR>")

    require("barbar").setup({
      animation = false,
      focus_on_close = "previous",
      icons = {
        preset = "default",
      },
    })
  end,
}
