local util = require("utils.setKeymap")
local keymap = util.keymap
local keymapVsc = util.keymapVsc
local keymapVscVisual = util.keymapVscVisual

-- map prefix
keymap("", "<Space>", "")

keymap("nxo", "gh", "^")
keymap("nxo", "gl", "$")
keymap("n", "gn", ":<C-u>noh<CR>")
keymap("n", "gs", ":<C-u><CR>:%s/", { silent = false })
keymap("n", "<CR>", "o<ESC>")

-- vscode
if vim.g.vscode then
  -- filer
  keymapVsc("n", "<Space>c", "workbench.action.closeSidebar")
  keymapVsc("n", "<Space>e", "workbench.view.explorer")
  -- global search
  keymapVsc("n", "#", "workbench.action.findInFiles", "{ 'query': expand('<cword>')}")
  keymapVscVisual("x", "#", "workbench.action.findInFiles", "{ 'query': expand('<cword>')}")
  -- comment
  keymapVsc("n", "gcc", "editor.action.commentLine")
  keymapVscVisual("x", "gc", "editor.action.commentLine")
  -- エラージャンプ
  keymapVsc("n", "g.", "editor.action.marker.nextInFiles")
  keymapVsc("n", "g,", "editor.action.marker.prevInFiles")
  -- フォーマット
  keymapVsc("n", "gf", "editor.action.formatDocument")
  -- インポート整理
  keymapVsc("n", "go", "editor.action.organizeImports")
  -- git graph
  keymapVsc("n", "zg", "git-graph.view")
  -- notification
  keymapVsc("n", "zn", "notifications.showList")
  keymapVsc("n", "zc", "notifications.clearAll")
else
  keymap("nx", "j", "gj")
  keymap("nx", "k", "gk")
  keymap("n", "<C-h>", ":<C-u>bprev<CR>")
  keymap("n", "<C-l>", ":<C-u>bnext<CR>")
  keymap("n", "<C-q>", "<C-w>w")
end
