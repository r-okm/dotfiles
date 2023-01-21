return function()
  local actions = require('telescope.actions')
  local telescope = require('telescope')

  telescope.setup {
    defaults = {
      mappings = {
        n = {
          ['q'] = actions.close
        }
      }
    },
    pickers = {
      find_files = { hidden = true, },
      git_files = { show_untracked = true, },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = 'smart_case',
      },
      workspaces = {},
    },
  }
end
