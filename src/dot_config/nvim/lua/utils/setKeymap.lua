local M = {}

local function getModesTableFromStr(modeStr)
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

local function appendCommonOpts(opts)
  local _opts = opts or {}

  if _opts.noremap == nil then
    _opts.noremap = true
  end
  if _opts.silent == nil then
    _opts.silent = true
  end

  return _opts
end

local function getRhsFromVsCmd(cmd, vs_args)
  local rhs
  if vs_args ~= nil then
    rhs = string.format("<Cmd> call VSCodeNotify('%s', %s)<Cr>", cmd, vs_args)
  else
    rhs = string.format("<Cmd> call VSCodeNotify('%s')<Cr>", cmd)
  end

  return rhs
end

local function getRhsFromVsVisualCmd(cmd, vs_args)
  local rhs
  if vs_args ~= nil then
    -- <Cmd> call VSCodeNotifyVisual()<Cr> の後に <Esc> を追記することでコマンド実行後にノーマルモードに移行する
    -- VSCodeNotifyVisual の第二引数に 0 を入れることで､コマンド実行後の vscode の文字選択状態を解除する
    rhs = string.format("<Cmd> call VSCodeCall('%s', %s)<Cr><Esc>", cmd, vs_args)
  else
    rhs = string.format("<Cmd> call VSCodeCall('%s')<Cr><Esc>", cmd)
  end

  return rhs
end

---vim,neovim コマンドのキーマップを設定する
---@param modeStr string コマンドを有効化するモード
---@param lhs string コマンドを発火させるキー
---@param rhs string|function コマンドの実行内容
---@param opts? table オプション
function M.keymap(modeStr, lhs, rhs, opts)
  local _modes = getModesTableFromStr(modeStr)
  local _opts = appendCommonOpts(opts)

  vim.keymap.set(_modes, lhs, rhs, _opts)
end

---vscode コマンドのキーマップを設定する
---@param modeStr string コマンドを有効化するモード
---@param lhs string コマンドを発火させるキー
---@param cmd string vscode command id
---@param vs_args? string vscode コマンドの引数
---@param opts? table オプション
function M.keymapVsc(modeStr, lhs, cmd, vs_args, opts)
  local _modes = getModesTableFromStr(modeStr)
  local _rhs = getRhsFromVsCmd(cmd, vs_args)
  local _opts = appendCommonOpts(opts)

  vim.keymap.set(_modes, lhs, _rhs, _opts)
end

---visual モード時の vscode コマンドのキーマップを設定する
---@param modeStr string コマンドを有効化するモード
---@param lhs string コマンドを発火させるキー
---@param cmd string vscode command id
---@param vs_args? string vscode コマンドの引数
---@param opts? table オプション
function M.keymapVscVisual(modeStr, lhs, cmd, vs_args, opts)
  local _modes = getModesTableFromStr(modeStr)
  local _rhs = getRhsFromVsVisualCmd(cmd, vs_args)
  local _opts = appendCommonOpts(opts)

  vim.keymap.set(_modes, lhs, _rhs, _opts)
end

return M
