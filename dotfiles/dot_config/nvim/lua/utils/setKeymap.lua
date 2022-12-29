local getModesTableFromStr = function(modeStr)
  -- 文字列を1字ずつ分割し配列に変換
  -- ex) "nx" => {"n", "x"}
  local modes = {}
  if modeStr == "" then
    table.insert(modes, "")
  else
    for i = 1, string.len(modeStr) do
      local mode = string.sub(modeStr, i, i)
      table.insert(modes, mode)
    end
  end
  return modes
end

local appendCommonOpts = function(opts)
  local _opts = opts or {}

  if _opts.noremap == nil then
    _opts.noremap = true
  end
  if _opts.silent == nil then
    _opts.silent = true
  end

  return _opts
end

local getRhsFromVsCmd = function(cmd, vs_args)
  local rhs
  if vs_args ~= nil then
    rhs = string.format("<Cmd> call VSCodeNotify('%s', %s)<Cr>", cmd, vs_args)
  else
    rhs = string.format("<Cmd> call VSCodeNotify('%s')<Cr>", cmd)
  end

  return rhs
end

local getRhsFromVsVisualCmd = function(cmd, vs_args)
  local rhs
  if vs_args ~= nil then
    -- <Cmd> call VSCodeNotifyVisual()<Cr> の後に <Esc> を追記することでコマンド実行後にノーマルモードに移行する
    -- VSCodeNotifyVisual の第二引数に 0 を入れることで､コマンド実行後の vscode の文字選択状態を解除する
    rhs = string.format("<Cmd> call VSCodeNotifyVisual('%s', 0, %s)<Cr><Esc>", cmd, vs_args)
  else
    rhs = string.format("<Cmd> call VSCodeNotifyVisual('%s', 0)<Cr><Esc>", cmd)
  end

  return rhs
end

local M = {}

M.keymap = function(modeStr, lhs, rhs, opts)
  local _modes = getModesTableFromStr(modeStr)
  local _opts = appendCommonOpts(opts)

  vim.keymap.set(_modes, lhs, rhs, _opts)
end

M.keymapVsc = function(modeStr, lhs, cmd, vs_args, opts)
  local _modes = getModesTableFromStr(modeStr)
  local _rhs = getRhsFromVsCmd(cmd, vs_args)
  local _opts = appendCommonOpts(opts)

  vim.keymap.set(_modes, lhs, _rhs, _opts)
end

M.keymapVscVisual = function(modeStr, lhs, cmd, vs_args, opts)
  local _modes = getModesTableFromStr(modeStr)
  local _rhs = getRhsFromVsVisualCmd(cmd, vs_args)
  local _opts = appendCommonOpts(opts)

  vim.keymap.set(_modes, lhs, _rhs, _opts)
end

return M
