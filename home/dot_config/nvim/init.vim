" 足りないプラグインがあれば :PlugInstall を実行
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Plugin
call plug#begin('~/.vim/plugged')
  let g:plug_url_format = 'git@github.com:%s.git'
  Plug 'vim-jp/vimdoc-ja'
  Plug 'tpope/vim-surround'
  Plug 'bronson/vim-visual-star-search'
  if exists('g:vscode')
    Plug 'asvetliakov/vim-easymotion'
  else
    Plug 'easymotion/vim-easymotion'
    Plug 'junegunn/fzf', {'dir': '~/.fzf_bin', 'do': './install --all'}
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'lambdalisue/fern.vim'
    Plug 'lambdalisue/gina.vim'
    Plug 'lambdalisue/nerdfont.vim'
    Plug 'lambdalisue/fern-renderer-nerdfont.vim'
    Plug 'nvim-treesitter/nvim-treesitter'
    Plug 'sainnhe/gruvbox-material'
    Plug 'tomtom/tcomment_vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
  endif
call plug#end()

" Misc
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

" Remap
" map prefix
let g:mapleader = "\<Space>"
nnoremap <Leader> <Nop>
xnoremap <Leader> <Nop>
" common mappings
inoremap <silent> <C-j> <esc>
nnoremap gh ^
xnoremap gh ^
nnoremap gl $
xnoremap gl $

" easymotion
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

" Vscode
if exists('g:vscode')
  " filer
  nnoremap <silent> <Leader>e <cmd>call VSCodeNotify('workbench.view.explorer')<cr>
  " cr
  nnoremap <silent> <cr> <cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>
  " buffer
  nmap <C-l> gt
  nmap <C-h> gT

  " insertmode を抜けた時に IME を OFF
  if executable('zenhan')
    autocmd InsertLeave * :call system('zenhan 0')
  endif
else
  " cr
  nnoremap <silent> <cr> o<esc>
  " buffer
  nmap <silent> <C-l> :<C-u>bnext<CR>
  nmap <silent> <C-h> :<C-u>bprev<CR>
  " window
  nnoremap sj <C-w>j
  nnoremap sk <C-w>k
  nnoremap sl <C-w>l
  nnoremap sh <C-w>h
  nnoremap ss :<C-u>sp<CR><C-w>j
  nnoremap sv :<C-u>vs<CR><C-w>l

  " insertmode を抜けた時に IME を OFF
  if executable('/mnt/c/scoop/shims/zenhan.exe')
    autocmd InsertLeave * :call system('/mnt/c/scoop/shims/zenhan.exe 0')
  endif

  source ~/.config/nvim/plugin-config-linux.vim
endif
