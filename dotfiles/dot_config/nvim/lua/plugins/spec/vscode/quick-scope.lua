return {
  "unblevable/quick-scope",
  keys = {
    { "f", mode = { "n", "x", "o" } },
    { "t", mode = { "n", "x", "o" } },
    { "F", mode = { "n", "x", "o" } },
    { "T", mode = { "n", "x", "o" } },
  },
  init = function()
    vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
    local set_hl = vim.api.nvim_set_hl
    set_hl(0, "QuickScopePrimary", { fg = "#afff5f", underline = true, nocombine = true })
    set_hl(0, "QuickScopeSecondary", { fg = "#5fffff", underline = true, nocombine = true })
  end,
}
