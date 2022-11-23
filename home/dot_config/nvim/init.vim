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
  Plug 'kana/vim-textobj-user'
  Plug 'osyo-manga/vim-textobj-multiblock'
  Plug 'kana/vim-operator-user'
  Plug 'kana/vim-operator-replace'
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
inoremap <silent> jk <esc>
nnoremap gh ^
xnoremap gh ^
nnoremap gl $
xnoremap gl $

" vim-textobj-multiblock
omap ab <Plug>(textobj-multiblock-a)
omap ib <Plug>(textobj-multiblock-i)
xmap ab <Plug>(textobj-multiblock-a)
xmap ib <Plug>(textobj-multiblock-i)

" vim-operator-replace
nmap , <Plug>(operator-replace)

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
  nnoremap <C-l> <cmd>call VSCodeNotify('workbench.action.nextEditorInGroup')<cr>
  nnoremap <C-h> <cmd>call VSCodeNotify('workbench.action.previousEditorInGroup')<cr>
  " window
  nnoremap sj <cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<cr>
  nnoremap sk <cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<cr>
  nnoremap sl <cmd>call VSCodeNotify('workbench.action.focusRightGroup')<cr>
  nnoremap sh <cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<cr>
  nnoremap ss <cmd>call VSCodeNotify('workbench.action.splitEditor')<cr>
  nnoremap sv <cmd>call VSCodeNotify('workbench.action.splitEditorOrthogonal')<cr>
  " git
  nnoremap zs <cmd>call VSCodeNotify('multiCommand.gitStatusWindow')<cr>
  nnoremap zd <cmd>call VSCodeNotify('git.openChange')<cr>
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

  source ~/.config/nvim/plugin-config-linux.vim
endif
