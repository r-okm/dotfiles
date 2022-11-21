" 足りないプラグインがあれば :PlugInstall を実行
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

"  Plugin
call plug#begin('~/.vim/plugged')
  let g:plug_url_format = 'git@github.com:%s.git'
  Plug 'tpope/vim-surround'
  Plug 'bronson/vim-visual-star-search'
  if exists('g:vscode')
    Plug 'asvetliakov/vim-easymotion'
  else
    Plug 'easymotion/vim-easymotion'
  endif
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
let g:mapleader = "\<Space>"
inoremap <silent> <C-j> <esc>
nnoremap gh ^
xnoremap gh ^
nnoremap gl $
xnoremap gl $
if exists('g:vscode')
  nmap <C-l> gt
  nmap <C-h> gT
  nnoremap <silent> <Leader>e <cmd>call VSCodeNotify('workbench.view.explorer')<cr>
  nnoremap <silent> <cr> <cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>
else
  nnoremap <silent> <cr> o<esc>
endif

"  easymotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1
let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_space_jump_first = 1
map f <Plug>(easymotion-fl)
map F <Plug>(easymotion-Fl)
map t <Plug>(easymotion-tl)
map T <Plug>(easymotion-Tl)
nmap ; <Plug>(easymotion-s2)
xmap ; <Plug>(easymotion-s2)

"  IME OFF
if executable('zenhan')
  autocmd InsertLeave * :call system('zenhan 0')
  autocmd CmdlineLeave * :call system('zenhan 0')
endif
