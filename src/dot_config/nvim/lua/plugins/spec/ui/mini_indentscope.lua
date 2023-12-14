local const = require("utils.const")

return {
  "echasnovski/mini.indentscope",
  cond = false,
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    -- 特定のファイルタイプでは無効にする
    local fts = const.HIGHLIGHT_DISABLED_FILETYPES
    for _, ft in ipairs(fts) do
      local cmd = string.format(
        [[
        augroup mini_indentscope_disable_%s
          autocmd!
          autocmd FileType %s lua vim.b.miniindentscope_disable = true
        augroup END
      ]],
        ft,
        ft
      )
      vim.cmd(cmd)
    end

    -- 規定の行数以上のファイルでは無効にする
    local cmd = string.format(
      [[
      function! s:disable_module()
        if line('$') > %d
          lua vim.b.miniindentscope_disable = true
        endif
      endfunction

      augroup mini_indentscope_disable_large_file
        autocmd!
        autocmd BufReadPost,BufNewFile * call s:disable_module()
      augroup END
    ]],
      const.LARGE_FILE_LINE_COUNT
    )
    vim.cmd(cmd)
  end,
  config = function()
    local mi = require("mini.indentscope")
    mi.setup({
      delay = 1,
      animation = mi.gen_animation.none(),
      symbol = "▏",
    })
  end,
}
