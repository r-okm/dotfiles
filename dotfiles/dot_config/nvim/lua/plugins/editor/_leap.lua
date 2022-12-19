return function()
  local leap = require('leap')
  leap.opts.safe_labels = {}
  leap.opts.labels = {
    "s", "f", "n",
    "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
    "u", "y", "v", "r", "g", "t", "c", "x", "/", "z"
  }

  local keymap = require('utils.setKeymap').keymap
  keymap('nxo', ';', '<Plug>(leap-forward-to)')
  keymap('nxo', '+', '<Plug>(leap-backward-to)')
end
