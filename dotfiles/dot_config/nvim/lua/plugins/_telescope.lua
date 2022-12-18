return function()
  local telescope = require('telescope')
  telescope.setup {
    pickers = {
      find_files = {
        hidden = true,
      },
      git_files = {
        show_untracked = true,
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  }
  telescope.load_extension('fzf')
  telescope.load_extension('neoclip')

  local builtin = require('telescope.builtin')
  local keymap = require('utils.setKeymap').keymap
  keymap('n', '<C-p>', builtin.git_files)
  keymap('n', '<C-o>', builtin.git_status)
  keymap('n', '<C-f>', builtin.live_grep)
  keymap('n', 'gp', ':<C-u>Telescope neoclip<CR>')
end
