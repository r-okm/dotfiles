local keymap = require("utils.setKeymap").keymap

return {
  "lambdalisue/fern.vim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "TheLeoP/fern-renderer-web-devicons.nvim",
  },
  keys = {
    { "<Space>e", mode = { "n" } }
  },
  config = function()
    keymap("n", "<Space>e", ":<C-u>Fern . -reveal=%<CR>")
    vim.g["fern#default_hidden"] = 1
    vim.g["fern#renderer"] = "nvim-web-devicons"
    vim.cmd([[
      function! s:init_fern() abort
        nmap <buffer> D <Plug>(fern-action-remove)
      endfunction

      augroup fern-custom
        autocmd! *
        autocmd FileType fern call s:init_fern()
      augroup END
    ]])
  end
}
