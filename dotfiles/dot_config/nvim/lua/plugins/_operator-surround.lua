return function()
  local keymap = require('utils.setKeymap').keymap
  keymap('nx', 'sa', '<Plug>(operator-surround-append)')
  keymap('n', 'sd', '<Plug>(operator-surround-delete)a')
  keymap('n', 'sr', '<Plug>(operator-surround-replace)a')
  keymap('x', 'sd', '<Plug>(operator-surround-delete)')
  keymap('x', 'sr', '<Plug>(operator-surround-replace)')
  keymap('n', 'sdd', '<Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)')
  keymap('n', 'srr', '<Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)')
end
