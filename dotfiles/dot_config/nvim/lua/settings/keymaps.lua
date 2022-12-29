local util = require("utils.setKeymap")
local keymap = util.keymap
local keymapVsc = util.keymapVsc
local keymapVscVisual = util.keymapVscVisual

-- map prefix
keymap("", "<Space>", "")

keymap("nxo", "gh", "^")
keymap("nxo", "gl", "$")
keymap("n", "<C-k><C-n>", ":<C-u>noh<CR>")
keymap("n", "<C-k><C-s>", ":<C-u><CR>:%s/", { silent = false })

-- vscode
if vim.g.vscode then
  -- buffer
  keymapVsc("n", "<Space>s", "workbench.action.files.save")
  keymapVsc("n", "<Space>S", "workbench.action.files.saveWithoutFormatting")
  keymapVsc("n", "<Space>w", "workbench.action.closeActiveEditor")
  keymapVsc("n", "<Space>t", "workbench.action.reopenClosedEditor")
  -- filer
  keymapVsc("n", "<Space>c", "workbench.action.closeSidebar")
  keymapVsc("n", "<Space>e", "workbench.view.explorer")
  -- insert new line in normal mode
  keymapVsc("n", "<Cr>", "editor.action.insertLineAfter")
  -- global search
  keymapVsc("n", "#", "workbench.action.findInFiles", "{ 'query': expand('<cword>')}")
  keymapVscVisual("x", "#", "workbench.action.findInFiles", "{ 'query': expand('<cword>')}")
  -- comment
  keymapVsc("n", "gcc", "editor.action.commentLine")
  keymapVscVisual("x", "gc", "editor.action.commentLine")
else
  keymap("n", "<CR>", "o<ESC>")
  keymap("n", "<C-h>", ":<C-u>bprev<CR>")
  keymap("n", "<C-l>", ":<C-u>bnext<CR>")
  keymap("n", "<Space>s", ":<C-u>w<CR>")
  keymap("n", "<Space>S", ":<C-u>noa w<CR>")
  keymap("n", "<C-q>", "<C-w>w")
end
