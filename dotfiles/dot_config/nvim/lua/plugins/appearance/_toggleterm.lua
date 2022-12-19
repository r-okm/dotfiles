return function()
  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({
    cmd = 'lazygit',
    direction = 'float',
    hidden = true
  })

  function LazygitToggle()
    lazygit:toggle()
  end

  local keymap = require('utils.setKeymap').keymap
  keymap('n', '<C-k><C-g>', '<cmd>lua LazygitToggle()<CR>')
end
