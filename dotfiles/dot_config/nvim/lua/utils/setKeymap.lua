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

local function _setKeymap(modeStr, lhs, rhs, opts)
  local modes = _getModes(modeStr)
  local _opts = opts or {}
  _opts.noremap = true
  _opts.silent = true
  vim.keymap.set(modes, lhs, rhs, _opts)
end

local M = {}

M.keymap = function(modeStr, lhs, rhs, opts)
  _setKeymap(modeStr, lhs, rhs, opts)
end

M.keymapVsc = function(modeStr, lhs, cmd, vs_args)
  local rhs
  if vs_args ~= nil then
    rhs = string.format('<Cmd> call VSCodeNotify("%s", %s)<Cr>', cmd, vs_args)
  else
    rhs = string.format('<Cmd> call VSCodeNotify("%s")<Cr>', cmd)
  end

  _setKeymap(modeStr, lhs, rhs)
end

M.keymapVscVisual = function(modeStr, lhs, cmd, vs_args)
  local rhs
  if vs_args ~= nil then
    -- <Cmd> call VSCodeNotifyVisual()<Cr> の後に <Esc> を追記することでコマンド実行後にノーマルモードに移行する
    -- VSCodeNotifyVisual の第二引数に 0 を入れることで､コマンド実行後の vscode の文字選択状態を解除する
    rhs = string.format('<Cmd> call VSCodeNotifyVisual("%s", 0, %s)<Cr><Esc>', cmd, vs_args)
  else
    rhs = string.format('<Cmd> call VSCodeNotifyVisual("%s", 0)<Cr><Esc>', cmd)
  end

  _setKeymap(modeStr, lhs, rhs)
end

return M
