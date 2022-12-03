-- plugin
vim.g.plug_url_format = 'git@github.com:%s.git'
local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.vim/plugged')
Plug 'vim-jp/vimdoc-ja'
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
local function getModes(modeStr)
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
  return modes
end

local function keymap(modeStr, lhs, rhs)
  local modes = getModes(modeStr)
  local common_keymap_opts = { noremap = true, silent = true }
  vim.keymap.set(modes, lhs, rhs, common_keymap_opts)
end

local function keymapVsc(modeStr, lhs, cmd, opts)
  local rhs
  if opts ~= nil then
    rhs = string.format('<Cmd> call VSCodeNotify("%s", %s)<Cr>', cmd, opts)
  else
    rhs = string.format('<Cmd> call VSCodeNotify("%s")<Cr>', cmd)
  end

  keymap(modeStr, lhs, rhs)
end

local function keymapVscVisual(modeStr, lhs, cmd, opts)
  local rhs
  if opts ~= nil then
    -- <Cmd> call VSCodeNotifyVisual()<Cr> の後に <Esc> を追記することでコマンド実行後にノーマルモードに移行する
    -- VSCodeNotifyVisual の第二引数に 0 を入れることで､コマンド実行後の vscode の文字選択状態を解除する
    rhs = string.format('<Cmd> call VSCodeNotifyVisual("%s", 0, %s)<Cr><Esc>', cmd, opts)
  else
    rhs = string.format('<Cmd> call VSCodeNotifyVisual("%s", 0)<Cr><Esc>', cmd)
  end

  keymap(modeStr, lhs, rhs)
end

-- map prefix
vim.g.mapleader = ' '
keymap('', '<Space>', '')

-- common mappings
keymap('nx', 'gh', '^')
keymap('nx', 'gl', '$')

-- vim-asterisk
keymap('nx', '*', '<Plug>(asterisk-gz*)')

-- vim-textobj-multiblock
keymap('ox', 'ab', '<Plug>(textobj-multiblock-a)')
keymap('ox', 'ib', '<Plug>(textobj-multiblock-i)')
vim.g.textobj_multiblock_blocks = {
  { "(", ")" },
  { "[", "]" },
  { "{", "}" },
  { '<', '>' },
  { '"', '"', 1 },
  { "'", "'", 1 },
  { "`", "`", 1 },
}


-- vim-operator-replace
keymap('nx', ',', '<Plug>(operator-replace)')

-- vim-opelator-surround
keymap('nx', 'sa', '<Plug>(operator-surround-append)')
keymap('n', 'sd', '<Plug>(operator-surround-delete)a')
keymap('n', 'sr', '<Plug>(operator-surround-replace)a')
keymap('x', 'sd', '<Plug>(operator-surround-delete)')
keymap('x', 'sr', '<Plug>(operator-surround-replace)')
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
  keymapVsc('n', '<Leader>c', 'workbench.action.closeSidebar')
  keymapVsc('n', '<Leader>e', 'workbench.view.explorer')
  keymapVsc('n', '<Leader>f', 'workbench.action.findInFiles')
  keymapVsc('n', '<Leader>g', 'workbench.view.scm')
  keymapVsc('n', '<Leader>d', 'workbench.view.debug')
  keymapVsc('n', '<Leader>x', 'workbench.view.extensions')
  keymapVsc('n', '<Leader>n', 'notifications.showList')
  keymapVsc('n', '<Leader>nc', 'notifications.clearAll')
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
end
