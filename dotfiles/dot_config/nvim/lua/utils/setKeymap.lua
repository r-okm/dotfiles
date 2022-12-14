local M = {}

local function _getModes(modeStr)
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

local function _setKeymap(modeStr, lhs, rhs)
  local modes = _getModes(modeStr)
  local common_keymap_opts = { noremap = true, silent = true }
  vim.keymap.set(modes, lhs, rhs, common_keymap_opts)
end

function M.keymap(modeStr, lhs, rhs)
  _setKeymap(modeStr, lhs, rhs)
end

function M.keymapVsc(modeStr, lhs, cmd, opts)
  local rhs
  if opts ~= nil then
    rhs = string.format('<Cmd> call VSCodeNotify("%s", %s)<Cr>', cmd, opts)
  else
    rhs = string.format('<Cmd> call VSCodeNotify("%s")<Cr>', cmd)
  end

  _setKeymap(modeStr, lhs, rhs)
end

function M.keymapVscVisual(modeStr, lhs, cmd, opts)
  local rhs
  if opts ~= nil then
    -- <Cmd> call VSCodeNotifyVisual()<Cr> の後に <Esc> を追記することでコマンド実行後にノーマルモードに移行する
    -- VSCodeNotifyVisual の第二引数に 0 を入れることで､コマンド実行後の vscode の文字選択状態を解除する
    rhs = string.format('<Cmd> call VSCodeNotifyVisual("%s", 0, %s)<Cr><Esc>', cmd, opts)
  else
    rhs = string.format('<Cmd> call VSCodeNotifyVisual("%s", 0)<Cr><Esc>', cmd)
  end

  _setKeymap(modeStr, lhs, rhs)
end

return M
