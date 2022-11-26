-- plugin
vim.g.plug_url_format = 'git@github.com:%s.git'
local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.vim/plugged')
Plug 'tpope/vim-repeat'
Plug 'haya14busa/vim-asterisk'
Plug 'ggandor/leap.nvim'
Plug 'ggandor/flit.nvim'
Plug 'kana/vim-textobj-user'
Plug 'osyo-manga/vim-textobj-multiblock'
Plug 'kana/vim-operator-user'
Plug 'kana/vim-operator-replace'
Plug 'rhysd/vim-operator-surround'
vim.call('plug#end')

-- set options
local set_options = {
  whichwrap = 'b,s,h,l,<,>,~,[,]',
  smartcase = true,
  ignorecase = true,
  clipboard = 'unnamedplus'
}
for k, v in pairs(set_options) do
  vim.api.nvim_set_option(k, v)
end

-- remap
local function keymap(modeStr, lhs, rhs)
  -- 文字列を1字ずつ分割し配列に変換
  -- ex) 'nx' => {'n', 'x'}
  local modes = {}
  if modeStr == '' then
    table.insert(modes, '')
  else
    for i = 1, string.len(modeStr) do
      local mode = string.sub(modeStr, i, i)
      table.insert(modes, mode)
    end
  end
  -- オプション
  local opts = { noremap = true, silent = true }

  vim.keymap.set(modes, lhs, rhs, opts)
end

-- map prefix
vim.g.mapleader = ' '
keymap('', '<Space>', '')

-- common mappings
keymap('i', 'jk', '<esc>')
keymap('nx', 'gh', '^')
keymap('nx', 'gl', '$')

-- vim-asterisk
keymap('nx', '*', '<Plug>(asterisk-gz*)')

-- vim-textobj-multiblock
keymap('ox', 'ab', '<Plug>(textobj-multiblock-a)')
keymap('ox', 'ib', '<Plug>(textobj-multiblock-i)')

-- vim-operator-replace
keymap('nx', ',', '<Plug>(operator-replace)')

-- vim-opelator-surround
keymap('nx', 'sa', '<Plug>(operator-surround-append)')
keymap('n', 'sdd', '<Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)')
keymap('n', 'srr', '<Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)')

-- leap.nvim
keymap('nxo', ';', '<Plug>(leap-forward-to)')
keymap('nxo', '+', '<Plug>(leap-backward-to)')
local leap = require('leap')
leap.opts.safe_labels = {}
leap.opts.labels = {
  "s", "f", "n",
  "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
  "u", "y", "v", "r", "g", "t", "c", "x", "/", "z"
}

-- flit.nvim
require('flit').setup {
  multiline = false
}

-- vscode
if vim.g.vscode then
  -- filer
  keymap('n', '<Leader>c', '<cmd>call VSCodeNotify("workbench.action.closeSidebar")<cr>')
  keymap('n', '<Leader>e', '<cmd>call VSCodeNotify("workbench.view.explorer")<cr>')
  keymap('n', '<Leader>f', '<cmd>call VSCodeNotify("workbench.action.findInFiles")<cr>')
  keymap('n', '<Leader>g', '<cmd>call VSCodeNotify("workbench.view.scm")<cr>')
  keymap('n', '<Leader>d', '<cmd>call VSCodeNotify("workbench.view.debug")<cr>')
  keymap('n', '<Leader>x', '<cmd>call VSCodeNotify("workbench.view.extensions")<cr>')
  keymap('n', '<Leader>n', '<cmd>call VSCodeNotify("notifications.showList")<cr>')
  keymap('n', '<Leader>nc', '<cmd>call VSCodeNotify("notifications.clearAll")<cr>')
  -- jumpToBracket
  keymap('nx', 'gb', '<cmd>call VSCodeNotify("editor.action.jumpToBracket")<cr>')
  -- insert new line in normal mode
  keymap('n', '<cr>', '<cmd>call VSCodeNotify("editor.action.insertLineAfter")<cr>')
  -- global search
  keymap('', '#', '<Cmd>call VSCodeNotify("workbench.action.findInFiles", { "query": expand("<cword>")})<CR>')
  -- git
  keymap('n', 'zs', '<cmd>call VSCodeNotify("multiCommand.gitStatusWindow")<cr>')
  keymap('n', 'zd', '<cmd>call VSCodeNotify("git.openChange")<cr>')
  keymap('x', 'za', '<cmd>call VSCodeNotifyVisual("git.stageSelectedRanges", 1)<cr>')
  keymap('x', 'zr', '<cmd>call VSCodeNotifyVisual("git.unstageSelectedRanges", 1)<cr>')
end
