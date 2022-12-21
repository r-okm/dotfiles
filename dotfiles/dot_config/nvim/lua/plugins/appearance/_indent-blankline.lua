return function()
  local set_hl = vim.api.nvim_set_hl

  local indent_color_1 = '#403b40'
  local indent_color_2 = '#353b35'
  local indent_color_3 = '#404039'
  local indent_color_4 = '#383d3d'

  set_hl(0, 'IndentBlanklineIndent1', { bg = indent_color_1, nocombine = true })
  set_hl(0, 'IndentBlanklineIndent2', { bg = indent_color_2, nocombine = true })
  set_hl(0, 'IndentBlanklineIndent3', { bg = indent_color_3, nocombine = true })
  set_hl(0, 'IndentBlanklineIndent4', { bg = indent_color_4, nocombine = true })

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
  }
end
