call plug#begin()
Plug 'joshdick/onedark.vim'
call plug#end()

colorscheme onedark
hi StatusLine guibg=#282c34 guibg=#abb2bf

set clipboard=unnamed
set whichwrap=b,s,h,l,<,>,~,[,]
set smartcase
set ignorecase
set incsearch
set hlsearch

set number
set relativenumber
set showtabline=2

nnoremap gh ^
xnoremap gh ^
onoremap gh ^
nnoremap gl $
xnoremap gl $
onoremap gl $
nnoremap gs :<C-u><CR>:%s/
nnoremap <CR> o<ESC>
nnoremap <C-h> gT
nnoremap <C-l> gt
nnoremap <Space>s :<C-u>write<CR>
nnoremap <Space>w :<C-u>q<CR>
nnoremap gn :<C-u>noh<CR>
