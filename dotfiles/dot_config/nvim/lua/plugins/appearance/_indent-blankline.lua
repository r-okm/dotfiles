return function()
  vim.cmd [[highlight IndentBlanklineIndent1 guibg=#403b40 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent2 guibg=#353b35 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent3 guibg=#383d3d gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent4 guibg=#454540 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineContextChar guifg=#CCCCCC gui=nocombine]]

  require("indent_blankline").setup {
    char = "",
    char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
    },
    space_char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
    },
    show_trailing_blankline_indent = false,
    show_current_context = true,
  }
end
