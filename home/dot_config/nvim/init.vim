" plugin
call plug#begin('~/.vim/plugged')
  let g:plug_url_format = 'git@github.com:%s.git'
  Plug 'tpope/vim-repeat'
  Plug 'bronson/vim-visual-star-search'
  Plug 'ggandor/leap.nvim'
  Plug 'ggandor/flit.nvim'
  Plug 'kana/vim-textobj-user'
  Plug 'osyo-manga/vim-textobj-multiblock'
  Plug 'kana/vim-operator-user'
  Plug 'kana/vim-operator-replace'
  Plug 'rhysd/vim-operator-surround'
  if exists('g:vscode')
    " add plugins only in vscode-neovim
  else
    Plug 'vim-jp/vimdoc-ja'
    Plug 'lambdalisue/fern.vim'
    Plug 'lambdalisue/nerdfont.vim'
    Plug 'lambdalisue/fern-renderer-nerdfont.vim'
    Plug 'sainnhe/gruvbox-material'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
  endif
call plug#end()

" set options
set whichwrap=b,s,h,l,<,>,~,[,]
set smartcase
set ignorecase
set nrformats=
set clipboard+=unnamedplus

" remap
" map prefix
let g:mapleader = "\<Space>"
nnoremap <Leader> <Nop>
xnoremap <Leader> <Nop>
" common mappings
inoremap jk <esc>
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

" vim-opelator-surround
map gsa <Plug>(operator-surround-append)
nmap gsdd <Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)
nmap gsrr <Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)

" leap
nnoremap s <Plug>(leap-forward-to)
xnoremap s <Plug>(leap-forward-to)
onoremap s <Plug>(leap-forward-to)
nnoremap S <Plug>(leap-backward-to)
xnoremap S <Plug>(leap-backward-to)
onoremap S <Plug>(leap-backward-to)
lua << EOF
local leap = require('leap')
leap.opts.safe_labels = {}
leap.opts.labels = {
  "s", "f", "n",
  "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
  "u", "y", "v", "r", "g", "t", "c", "x", "/", "z"
}
EOF

" flit
lua << EOF
local flit = require('flit')
flit.setup {
  multiline = false
}
EOF

" vscode
if exists('g:vscode')
  " filer
  nnoremap <Leader>e <cmd>call VSCodeNotify('workbench.view.explorer')<cr>
  " jumpToBracket
  nnoremap gb <cmd>call VSCodeNotify('editor.action.jumpToBracket')<cr>
  xnoremap gb <cmd>call VSCodeNotify('editor.action.jumpToBracket')<cr>
  " insert new line in normal mode
  nnoremap <cr> <cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>
  " git
  nnoremap zs <cmd>call VSCodeNotify('multiCommand.gitStatusWindow')<cr>
  nnoremap zd <cmd>call VSCodeNotify('git.openChange')<cr>
else
  " jumpToBracket
  nnoremap gb %
  xnoremap gb %
  " insert new line in normal mode
  nnoremap <cr> o<esc>
  " buffer
  nmap <silent> <C-l> :<C-u>bnext<CR>
  nmap <silent> <C-h> :<C-u>bprev<CR>

  " set options
  set termguicolors
  set number
  set list
  set listchars=tab:»-,trail:_
  set expandtab
  set tabstop=2
  set shiftwidth=2

  " airline
  let g:airline#extensions#tabline#enabled = 1

  "" fern
  nnoremap <silent> <Leader>e :<C-u>Fern . -drawer<CR>
  nnoremap <silent> <Leader>E :<C-u>Fern . -drawer -reveal=%<CR>
  let g:fern#default_hidden=1
  let g:fern#renderer = 'nerdfont'

  "" gruvbox
  colorscheme gruvbox-material
endif
