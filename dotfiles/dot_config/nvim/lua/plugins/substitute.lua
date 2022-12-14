return function()
  local keymap = require('utils.setKeymap').keymap
  keymap('nx', ',', '<cmd>lua require("substitute").operator()<cr>')
end
