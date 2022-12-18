local jetpackfile = vim.fn.stdpath('data') .. '/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim'
local jetpackurl = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"

if vim.fn.filereadable(jetpackfile) == 0 then
  vim.fn.system(string.format('curl -fsSLo %s --create-dirs %s', jetpackfile, jetpackurl))
end

vim.cmd('packadd vim-jetpack')

local jetpack = require('jetpack')
for _, name in ipairs(jetpack.names()) do
  if not jetpack.tap(name) then
    jetpack.sync()
    break
  end
end

require('jetpack.packer').startup(function(use)
  use { 'tani/vim-jetpack', opt = true }
  use { 'vim-jp/vimdoc-ja' }
  use { 'tpope/vim-repeat' }
  use { 'haya14busa/vim-asterisk', config = require('plugins._asterisk') }
  use { 'ggandor/leap.nvim', config = require('plugins._leap') }
  use { 'ggandor/flit.nvim', config = require('plugins._flit') }
  use { 'kana/vim-textobj-user' }
  use { 'osyo-manga/vim-textobj-multiblock', config = require('plugins._textobj-multiblock') }
  use { 'kana/vim-operator-user' }
  use { 'gbprod/substitute.nvim', config = require('plugins._substitute') }
  use { 'rhysd/vim-operator-surround', config = require('plugins._operator-surround') }

  if not vim.g.vscode then
    -- lsp
    use { 'neovim/nvim-lspconfig' }
    use {
      'williamboman/mason.nvim',
      config = require('plugins._mason'),
    }
    use {
      'williamboman/mason-lspconfig.nvim',
      config = require('plugins._mason-lspconfig'),
    }
    use {
      'jose-elias-alvarez/null-ls.nvim',
      config = require('plugins._null-ls')
    }
    -- cmp
    use {
      'hrsh7th/nvim-cmp',
      config = require('plugins._nvim-cmp'),
    }
    use { 'hrsh7th/cmp-nvim-lsp' }
    use { 'hrsh7th/vim-vsnip' }
    use { 'hrsh7th/cmp-buffer' }
    use { 'hrsh7th/cmp-path' }
    use { 'hrsh7th/cmp-cmdline' }

    -- treesitter
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = require('plugins._treesitter'),
    }
    use {
      'windwp/nvim-autopairs',
      config = require('plugins._autopairs')
    }
    use {
      'RRethy/vim-illuminate',
      config = require('plugins._illuminate')
    }

    -- telescope
    use {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.0',
      config = require('plugins._telescope'),
    }
    use { 'nvim-lua/plenary.nvim' }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    use {
      'AckslD/nvim-neoclip.lua',
      config = require('plugins._neoclip'),
    }

    -- Comment
    use {
      'numToStr/Comment.nvim',
      config = require('plugins._comment')
    }
    -- indent line
    use {
      'lukas-reineke/indent-blankline.nvim',
      config = require('plugins._indent-blankline'),
    }

    -- terminal
    use {
      'akinsho/toggleterm.nvim',
      config = require('plugins._toggleterm'),
    }

    -- sidebar
    use {
      'nvim-tree/nvim-tree.lua',
      config = require('plugins._nvim-tree')
    }
    -- tab
    use {
      'akinsho/bufferline.nvim',
      config = require('plugins._bufferline')
    }
    use { 'nvim-tree/nvim-web-devicons', as = 'tree-web-devicons' }

    -- delete buffer without closing window
    use {
      'famiu/bufdelete.nvim',
      config = require('plugins._bufdelete'),
    }

    -- statusbar
    use {
      'nvim-lualine/lualine.nvim',
      config = require('plugins._lualine')
    }
    use { 'kyazdani42/nvim-web-devicons', as = 'lualine-web-devicons', opt = true }

    -- gitsign
    use {
      'lewis6991/gitsigns.nvim',
      tag = 'release',
      config = require('plugins._gitsigns'),
    }

    -- color theme
    use {
      'ellisonleao/gruvbox.nvim',
      config = require('plugins._gruvbox')
    }
  end
end)
