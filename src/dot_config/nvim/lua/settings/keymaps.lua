local utils = require("utils.setKeymap")
local keymap = utils.keymap
local keymapVsc = utils.keymapVsc
local keymapVscVisual = utils.keymapVscVisual

-- map prefix
keymap("", "<Space>", "")

keymap("nxo", "gh", "^")
keymap("nxo", "gl", "$")
keymap("n", "gn", ":<C-u>noh<CR>")
keymap("n", "gs", ":<C-u><CR>:%s/", { silent = false })
keymap("n", "<CR>", "o<ESC>")

-- vscode
if vim.g.vscode then
  -- save
  keymapVsc("n", "<Space>s", "workbench.action.files.save")
  keymapVsc("n", "<Space>S", "workbench.action.files.saveWithoutFormatting")
  -- close
  keymapVsc("n", "<Space>w", "workbench.action.closeActiveEditor")
  -- tab
  keymapVsc("n", "L", "workbench.action.moveEditorRightInGroup")
  keymapVsc("n", "H", "workbench.action.moveEditorLeftInGroup")
  -- filer
  keymapVsc("n", "<Space>c", "workbench.action.closeSidebar")
  keymapVsc("n", "<Space>e", "workbench.view.explorer")
  -- global search
  keymapVsc("n", "#", "workbench.action.findInFiles", "{ 'query': expand('<cword>')}")
  -- comment
  keymapVsc("n", "gcc", "editor.action.commentLine")
  keymapVscVisual("x", "gc", "editor.action.commentLine")
  keymapVsc("n", "gbc", "editor.action.blockComment")
  keymapVscVisual("x", "gb", "editor.action.blockComment")
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
  -- notification
  keymapVsc("n", "zn", "notifications.showList")
  keymapVsc("n", "zc", "notifications.clearAll")
  -- project_files
  keymapVsc("n", "zp", "workbench.action.quickOpen")
  -- find_files
  keymapVsc("n", "zf", "workbench.action.findInFiles")
else
  keymap("n", "<C-h>", ":<C-u>bprev<CR>")
  keymap("n", "<C-l>", ":<C-u>bnext<CR>")
  keymap("n", "<C-q>", "<C-w>w")
  keymap("n", "<Space>s", ":<C-u>write<CR>")
  keymap("n", "<Space>S", ":<C-u>noa write<CR>")
  -- terminal-job モードへ切り替える
  keymap("t", "<C-k><C-n>", "<C-\\><C-n>")
  keymap("n", "<C-k><C-n>", ":<C-u>terminal<CR>")
end
