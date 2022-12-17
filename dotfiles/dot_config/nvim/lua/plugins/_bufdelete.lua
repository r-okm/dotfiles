return function()
  local keymap = require('utils.setKeymap').keymap
  keymap('n', '<Leader>w', function()
    return require('bufdelete').bufwipeout(0)
  end)
end
