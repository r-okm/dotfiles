require('settings.keymaps')
require('settings.options')
require('plugins')
if not vim.g.vscode then
  require('settings.lsp')
end
