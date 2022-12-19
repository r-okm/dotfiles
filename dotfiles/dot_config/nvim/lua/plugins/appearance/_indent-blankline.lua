return function()
  vim.cmd [[highlight IndentBlanklineIndent1 guibg=#383138 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent2 guibg=#2e362e gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent3 guibg=#303838 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent4 guibg=#36362f gui=nocombine]]
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
