local keymap = require("utils.setKeymap").keymap
local getVisualSelection = require("utils.buffer").getVisualSelection

return {
  "nvim-telescope/telescope.nvim",
  version = "0.1.4",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzy-native.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<C-p>", mode = { "n" } },
    { "<C-g>", mode = { "n" } },
    { "<C-f>", mode = { "n" } },
  },
  init = function()
    local actions = require("telescope.actions")
    local telescope = require("telescope")

    telescope.setup {
      defaults = {
        mappings = {
          n = {
            ["q"] = actions.close
          }
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--line-number",
          "--column",
          "--only-matching",
          "--hidden",
          "--smart-case",
          "--glob",
          "!**/.git/*",
          "--glob",
          "!**/node_modules/*",
          "--glob",
          "!**/package-lock.json",
        }
      },
      pickers = {
        find_files = {
          find_command = {
            "rg",
            "--color=never",
            "--files",
            "--hidden",
            "--no-ignore",
            "--smart-case",
            "--glob",
            "!**/.git/*",
            "--glob",
            "!**/node_modules/*",
          },
        },
        grep_string = { initial_mode = "normal" },
      },
      extensions = {
        fzy_native = {
          override_generic_sorter = false,
          override_file_sorter = true,
        },
      },
    }
  end,
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.load_extension("fzy_native")

    keymap("n", "zp", builtin.find_files)
    keymap("n", "zf", builtin.live_grep)
    keymap("n", "#", builtin.grep_string)
    keymap("x", "#", function()
      local text = getVisualSelection()
      builtin.grep_string({ search = text })
    end)
  end
}
