return function()
  if vim.g.vscode then
    return
  end

  -- lazygit
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

  -- toggleterm
  require('toggleterm').setup({
    direction = 'float',
    -- direction = 'vertical',
    -- size = function()
    --   return vim.o.columns * 0.5
    -- end,
  })
  keymap('n', '<C-n>', ':ToggleTerm<CR>')

  function _G.set_terminal_keymaps()
    local opts = { buffer = 0 }
    vim.keymap.set('t', '<CR>', [[<CR>]], opts)
    vim.keymap.set('t', '<ESC>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-n>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
  end

  vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')
end
