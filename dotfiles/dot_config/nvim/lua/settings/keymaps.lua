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
  -- undo/redo
  keymapVsc("n", "u", "undo", nil, { noremap = false })
  keymapVsc("n", "<C-r>", "redo", nil, { noremap = false })
  -- filer
  keymapVsc("n", "<Space>c", "workbench.action.closeSidebar")
  keymapVsc("n", "<Space>e", "workbench.view.explorer")
  -- global search
  keymapVsc("n", "#", "workbench.action.findInFiles", "{ 'query': expand('<cword>')}")
  -- comment
  keymapVsc("n", "gcc", "editor.action.commentLine")
  keymapVscVisual("x", "gc", "editor.action.commentLine")
  -- 戻る､進む
  keymapVsc("n", "zh", "workbench.action.navigateBack")
  keymapVsc("n", "zl", "workbench.action.navigateForward")
  -- エラージャンプ
  keymapVsc("n", "g.", "editor.action.marker.nextInFiles")
  keymapVsc("n", "g,", "editor.action.marker.prevInFiles")
  -- 定義ジャンプ
  keymapVsc("n", "gD", "editor.action.goToImplementation")
  -- フォーマット
  keymapVsc("n", "gf", "editor.action.formatDocument")
  keymapVscVisual("x", "gf", "editor.action.formatSelection")
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
