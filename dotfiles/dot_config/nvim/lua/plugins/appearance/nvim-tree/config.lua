return function()
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  local keymap = require('utils.setKeymap').keymap
  keymap('n', '<Space>e', ':<C-u>NvimTreeFindFile<Cr>')

  require('nvim-tree').setup {
    view = {
      width = 40,
      mappings = {
        list = {
          { key = 'h', action = 'close_node' },
          { key = 'l', action = 'preview' },
          { key = 'v', action = 'vsplit' },
        },
      },
    },
    -- open_on_setup = true,
    update_focused_file = {
      enable = true,
    },
    update_cwd = true,
    system_open = {
      cmd = 'xdg-open',
    },
    git = {
      ignore = false,
    },
    renderer = {
      add_trailing = true,
      indent_markers = {
        enable = true,
        icons = {
          corner = "└", edge = "", item = "│", bottom = "─", none = " ",
        },
      },
      icons = {
        show = {
          folder = false,
        },
        glyphs = {
          git = {
            unstaged = "E",
            staged = "S",
            unmerged = "",
            renamed = "➜",
            untracked = "N",
            deleted = "D",
            ignored = 'ﮖ',
          }
        }
      },
      special_files = {},
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
