return function()
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  local keymap = require("utils.setKeymap").keymap
  keymap("n", "<Space>e", ":<C-u>NvimTreeFindFile<Cr>")

  require("nvim-tree").setup {
    view = {
      width = 40,
      mappings = {
        list = {
          { key = "h", action = "close_node" },
          { key = "l", action = "preview" },
          { key = "v", action = "vsplit" },
        },
      },
      hide_root_folder = true,
    },
    update_focused_file = {
      enable = true,
    },
    update_cwd = true,
    system_open = {
      cmd = "xdg-open",
    },
    git = {
      ignore = false,
      show_on_open_dirs = false,
    },
    renderer = {
      indent_markers = {
        enable = true,
        icons = {
          corner = "└", edge = "│", item = "│", bottom = "─", none = " ",
        },
      },
      icons = {
        show = {
          folder_arrow = false,
        },
        glyphs = {
          git = {
            unstaged = "E",
            staged = "S",
            unmerged = "",
            renamed = "➜",
            untracked = "N",
            deleted = "D",
            ignored = "◌",
          }
        },
        git_placement = "signcolumn",
      },
      special_files = {},
      group_empty = true,
    },
    actions = {
      change_dir = {
        enable = false,
      },
      remove_file = {
        close_window = false,
      },
    },
  }
end
