return function()
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  -- empty setup using defaults
  require("nvim-tree").setup {
    open_on_setup = true,
    view = {
      mappings = {
        list = {
          { key = 'h', action = 'close_node' },
          { key = 'l', action = 'preview' },
          { key = 'v', action = 'vsplit' }
        }
      }
    }
  }

  local keymap = require('utils.setKeymap').keymap
  keymap('n', '<Leader>e', ':NvimTreeFocus<Cr>')
end