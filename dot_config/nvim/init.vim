"  Plugin
call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-surround'
call plug#end()

"  Misc
set number
set expandtab
set whichwrap=b,s,h,l,<,>,~,[,]
set nrformats=
set clipboard+=unnamedplus

"  Remap
inoremap <silent> jk <esc>
nnoremap c "_c

"  Vscode
if exists('g:vscode')
  "  Focus Explorer
  cnoremap ee<cr> <cmd>call VSCodeNotify('workbench.view.explorer')<cr><esc>
  "  Close Primary Sidebar
  cnoremap cs<cr> <cmd>call VSCodeNotify('workbench.action.closeSidebar')<cr><esc>
endif
