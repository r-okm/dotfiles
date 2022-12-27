return function()
  if vim.g.vscode then return end

  local telescope = require('telescope')
  local builtin = require('telescope.builtin')

  telescope.load_extension('fzf')
  telescope.load_extension('neoclip')
  telescope.load_extension('workspaces')

  telescope.project_files = function()
    local ok = pcall(builtin.git_files)
    if not ok then builtin.find_files() end
  end

  local keymap = require('utils.setKeymap').keymap
  keymap('n', '<C-p>', telescope.project_files)
  keymap('n', '<C-g>', builtin.git_status)
  keymap('n', '<C-f>', builtin.live_grep)
  keymap('n', 'gp', ':<C-u>Telescope neoclip<CR>')
  keymap('n', '<C-k><C-r>', ':<C-u>Telescope workspaces<CR>')
end
