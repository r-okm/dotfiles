local M = {}

-- 巨大ファイルと判定する行数
M.LARGE_FILE_LINE_COUNT = 5000
-- ハイライトを無効にするファイルタイプのリスト
M.HIGHLIGHT_DISABLED_FILETYPES = { "help", "lazy", "fern" }

return M
