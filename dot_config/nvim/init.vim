"  Plugin
call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-surround'
  Plug 'bronson/vim-visual-star-search'
call plug#end()

"  Misc
set number
set expandtab
set tabstop=4
set shiftwidth=4
set whichwrap=b,s,h,l,<,>,~,[,]
set smartcase
set ignorecase
set nrformats=
set clipboard+=unnamedplus

"  Remap
inoremap <silent> <C-j> <esc>
nnoremap gh ^
nnoremap gl $
xnoremap gh ^
xnoremap gl $

"  IME OFF
if executable('zenhan')
  autocmd InsertLeave * :call system('zenhan 0')
  autocmd CmdlineLeave * :call system('zenhan 0')
endif

"  Vscode
if exists('g:vscode')
  "  Focus Explorer
  cnoremap ee<cr> <cmd>call VSCodeNotify('workbench.view.explorer')<cr><esc>
  "  Close Primary Sidebar
  cnoremap cs<cr> <cmd>call VSCodeNotify('workbench.action.closeSidebar')<cr><esc>
endif
