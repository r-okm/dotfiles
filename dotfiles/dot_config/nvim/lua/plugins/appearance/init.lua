return function(use)
  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = require('plugins.appearance._treesitter'),
  }
  use {
    'windwp/nvim-autopairs',
    config = require('plugins.appearance._autopairs')
  }
  use {
    'RRethy/vim-illuminate',
    config = require('plugins.appearance._illuminate')
  }

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    config = require('plugins.appearance._telescope'),
  }
  use { 'nvim-lua/plenary.nvim' }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use {
    'AckslD/nvim-neoclip.lua',
    config = require('plugins.appearance._neoclip'),
  }

  -- Comment
  use {
    'numToStr/Comment.nvim',
    config = require('plugins.appearance._comment')
  }
  -- indent line
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = require('plugins.appearance._indent-blankline'),
  }

  -- terminal
  use {
    'akinsho/toggleterm.nvim',
    config = require('plugins.appearance._toggleterm'),
  }

  -- sidebar
  use {
    'nvim-tree/nvim-tree.lua',
    config = require('plugins.appearance._nvim-tree')
  }
  -- tab
  use {
    'akinsho/bufferline.nvim',
    config = require('plugins.appearance._bufferline')
  }
  use { 'nvim-tree/nvim-web-devicons', as = 'tree-web-devicons' }

  -- delete buffer without closing window
  use {
    'famiu/bufdelete.nvim',
    config = require('plugins.appearance._bufdelete'),
  }

  -- statusbar
  use {
    'nvim-lualine/lualine.nvim',
    config = require('plugins.appearance._lualine')
  }
  use { 'kyazdani42/nvim-web-devicons', as = 'lualine-web-devicons', opt = true }

  -- gitsign
  use {
    'lewis6991/gitsigns.nvim',
    tag = 'release',
    config = require('plugins.appearance._gitsigns'),
  }

  -- color theme
  use {
    'ellisonleao/gruvbox.nvim',
    config = require('plugins.appearance._gruvbox')
  }

end
