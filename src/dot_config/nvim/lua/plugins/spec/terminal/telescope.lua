local keymap = require("utils.setKeymap").keymap
local getVisualSelection = require("utils.buffer").getVisualSelection

return {
  "nvim-telescope/telescope.nvim",
  commit = "fac83a556e7b710dc31433dec727361ca062dbe9",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzy-native.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "zp", mode = { "n" } },
    { "zf", mode = { "n" } },
    { "#", mode = { "n", "x" } },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local previewers = require("telescope.previewers")

    telescope.setup({
      defaults = {
        mappings = {
          n = {
            ["q"] = actions.close,
          },
          i = {
            ["<esc>"] = actions.close,
          },
        },
        layout_config = {
          horizontal = {
            height = 0.9,
            preview_cutoff = 120,
            prompt_position = "bottom",
            width = 0.9,
            preview_width = 0.7,
          },
        },
        layout_strategy = "vertical",
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--line-number",
          "--column",
          "--only-matching",
          "--hidden",
          "--smart-case",
          "--trim",
          "--glob",
          "!**/.git/*",
          "--glob",
          "!**/node_modules/*",
          "--glob",
          "!**/package-lock.json",
        },
        path_display = {
          filename_first = {
            reverse_directories = true,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--exclude",
            ".git",
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
    })
    telescope.load_extension("fzy_native")

    local my_git_status = function(opts)
      opts = opts or {}
      opts.previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          return { "git", "-c", "delta.side-by-side=true", "diff", entry.value }
        end,
      })

      builtin.git_status(opts)
    end

    keymap("n", "zp", builtin.find_files)
    keymap("n", "zf", builtin.live_grep)
    keymap("n", "zo", my_git_status)
    keymap("n", "#", builtin.grep_string)
    keymap("x", "#", function()
      local text = getVisualSelection()
      builtin.grep_string({ search = text })
    end)
  end,
}
