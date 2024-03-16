local keymap = require("utils.setKeymap").keymap

return {
  "lambdalisue/fern.vim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "TheLeoP/fern-renderer-web-devicons.nvim",
    "yuki-yano/fern-preview.vim",
    "lambdalisue/fern-hijack.vim",
  },
  event = { "CmdlineEnter", "BufEnter" },
  keys = {
    { "<Space>e", mode = { "n" } },
  },
  config = function()
    keymap("n", "<Space>e", ":<C-u>Fern . -reveal=% -drawer -width=60<CR>")
    vim.g["fern#default_hidden"] = 1
    vim.g["fern#renderer"] = "nvim-web-devicons"
    vim.cmd([[
      function! s:init_fern() abort
        nnoremap <silent> <Plug>(fern-my-close-drawer) :<C-u>FernDo close -drawer -stay<CR>
        nnoremap <silent> <expr>
          \ <Plug>(fern-my-open-or-expand)
          \ fern#smart#leaf(
          \  "<Plug>(fern-action-open)<Plug>(fern-my-close-drawer)",
          \  "<Plug>(fern-action-expand)",
          \ )

        nmap <silent> <buffer> <CR> <Plug>(fern-my-open-or-expand)
        nmap <silent> <buffer> l <Plug>(fern-my-open-or-expand)
        nmap <silent> <buffer> q <Plug>(fern-my-close-drawer)
        nmap <silent> <buffer> D <Plug>(fern-action-remove)
        nmap <silent> <buffer> <C-v> <Plug>(fern-action-preview:auto:toggle)
        nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
        nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
      endfunction

      augroup fern-custom
        autocmd! *
        autocmd FileType fern call s:init_fern()
      augroup END
    ]])
  end,
}
