"  Plugin
call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-surround'
call plug#end()

"  Misc
set number
set expandtab
set whichwrap=b,s,h,l,<,>,~,[,]
set nrformats=

"  Clipboard
set clipboard+=unnamedplus
let g:clipboard = {
  \   'name': 'win32yank-wsl',
  \   'copy': {
  \      '+': 'win32yank -i --crlf',
  \      '*': 'win32yank -i --crlf',
  \    },
  \   'paste': {
  \      '+': 'win32yank -o --lf',
  \      '*': 'win32yank -o --lf',
  \   },
  \   'cache_enabled': 0,
  \ }

"  IME OFF
if executable('zenhan')
  autocmd InsertLeave * :call system('zenhan 0')
  autocmd CmdlineLeave * :call system('zenhan 0')
endif

"  Remap
inoremap <silent> jk <esc>

"  Vscode
if exists('g:vscode')
  "  Focus Explorer
  cnoremap e<cr> <cmd>call VSCodeNotify('workbench.view.explorer')<cr><esc>
  "  Carriage return
  nnoremap <cr> <cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>
else
  "  Carriage return
  nnoremap <silent> <cr> o<esc>
endif
