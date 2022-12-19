return function()
  vim.g.textobj_multiblock_blocks = {
    { "(", ")" },
    { "[", "]" },
    { "{", "}" },
    { '<', '>' },
    { '"', '"', 1 },
    { "'", "'", 1 },
    { "`", "`", 1 },
  }

  local keymap = require('utils.setKeymap').keymap
  keymap('ox', 'ab', '<Plug>(textobj-multiblock-a)')
  keymap('ox', 'ib', '<Plug>(textobj-multiblock-i)')
end
