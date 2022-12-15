local util = require('utils.setKeymap')
local keymap = util.keymap
local keymapVsc = util.keymapVsc
local keymapVscVisual = util.keymapVscVisual

-- map prefix
vim.g.mapleader = ' '
keymap('', '<Space>', '')

keymap('nx', 'gh', '^')
keymap('nx', 'gl', '$')

-- vscode
if vim.g.vscode then
  -- buffer
  keymapVsc('n', '<Leader>s', 'workbench.action.files.save')
  keymapVsc('n', '<Leader>w', 'workbench.action.closeActiveEditor')
  keymapVsc('n', '<Leader>t', 'workbench.action.reopenClosedEditor')
  -- filer
  keymapVsc('n', '<Leader>c', 'workbench.action.closeSidebar')
  keymapVsc('n', '<Leader>e', 'workbench.view.explorer')
  -- jumpToBracket
  keymapVsc('nx', 'gb', 'editor.action.jumpToBracket')
  -- insert new line in normal mode
  keymapVsc('n', '<Cr>', 'editor.action.insertLineAfter')
  -- global search
  keymapVsc('n', '#', 'workbench.action.findInFiles', '{ "query": expand("<cword>")}')
  keymapVscVisual('x', '#', 'workbench.action.findInFiles', '{ "query": expand("<cword>")}')
  -- git
  keymapVsc('n', 'zs', 'multiCommand.gitStatusWindow')
  keymapVsc('n', 'zd', 'git.openChange')
  keymapVscVisual('x', 'za', 'git.stageSelectedRanges')
  keymapVscVisual('x', 'zr', 'git.unstageSelectedRanges')
else
  keymap('n', '<CR>', 'o<ESC>')
  keymap('n', '<C-h>', ':<C-u>bprev<CR>')
  keymap('n', '<C-l>', ':<C-u>bnext<CR>')
  keymap('n', '<Leader>s', ':<C-u>w<CR>')
  keymap('n', '<Leader>w', ':<C-u>bw<CR>:<C-u>bp<CR>')
end
