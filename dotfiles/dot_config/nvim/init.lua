-- plugin
local jetpackfile = vim.fn.stdpath('data') .. '/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim'
local jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"
if vim.fn.filereadable(jetpackfile) == 0 then
  vim.fn.system(string.format('curl -fsSLo %s --create-dirs %s', jetpackfile, jetpackurl))
end

vim.cmd('packadd vim-jetpack')

local jetpack = require('jetpack')
for _, name in ipairs(jetpack.names()) do
  if not jetpack.tap(name) then
    jetpack.sync()
    break
  end
end

require('jetpack.packer').startup(function(use)
  use { 'tani/vim-jetpack', opt = 1 }
  use 'vim-jp/vimdoc-ja'
  use 'tpope/vim-repeat'
  use 'haya14busa/vim-asterisk'
  use 'ggandor/leap.nvim'
  use 'ggandor/flit.nvim'
  use 'kana/vim-textobj-user'
  use 'osyo-manga/vim-textobj-multiblock'
  use 'kana/vim-operator-user'
  use 'gbprod/substitute.nvim'
  use 'rhysd/vim-operator-surround'
end)

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

-- wsl でホストとクリップボードを共有
local win32yank = '/mnt/c/scoop/shims/win32yank.exe'
if vim.fn.has('wsl') == 1 and vim.fn.executable(win32yank) == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = win32yank .. " -i --crlf",
      ["*"] = win32yank .. " -i --crlf",
    },
    paste = {
      ["+"] = win32yank .. " -o --lf",
      ["*"] = win32yank .. " -o --lf",
    },
    cache_enable = 0,
  }
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


-- substitute.nvim
keymap('nx', ',', '<cmd>lua require("substitute").operator()<cr>')

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
  vim.o.number = true
  vim.o.relativenumber = true
end
