"  Plugin
call plug#begin('~/.vim/plugged')
  let g:plug_url_format = 'git@github.com:%s.git'
  Plug 'tpope/vim-surround'
  Plug 'bronson/vim-visual-star-search'
  Plug 'rhysd/clever-f.vim'
  if exists('g:vscode')
    Plug 'asvetliakov/vim-easymotion'
  else
    Plug 'easymotion/vim-easymotion'
  endif
  let g:EasyMotion_do_mapping = 0
  let g:EasyMotion_smartcase = 1
  let g:EasyMotion_enter_jump_first = 1
  let g:EasyMotion_space_jump_first = 1
call plug#end()

"  Misc
set number
set list
set listchars=tab:»-,trail:_
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
xnoremap gh ^
nnoremap gl $
xnoremap gl $
nmap s <Plug>(easymotion-s2)
xmap s <Plug>(easymotion-s2)
if exists('g:vscode')
  nnoremap <silent> <cr> <cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>
else
  nnoremap <silent> <cr> o<esc>
endif

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
