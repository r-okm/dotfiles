return function()
  local keymap = require('utils.setKeymap').keymap
  keymap('nx', '*', '<Plug>(asterisk-gz*)')
end
