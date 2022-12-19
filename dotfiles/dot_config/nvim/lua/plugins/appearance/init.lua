return function(use)
  local _use = function(opts)
    opts.cond = function()
      return vim.g.vscode == nil
    end
    use(opts)
  end

  -- treesitter
  _use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = require('plugins.appearance._treesitter'),
  }
  _use {
    'windwp/nvim-autopairs',
    config = require('plugins.appearance._autopairs'),
    after = { 'nvim-treesitter', 'nvim-cmp' },
  }
  _use {
    'RRethy/vim-illuminate',
    config = require('plugins.appearance._illuminate'),
    after = { 'nvim-treesitter' },
  }

  -- telescope
  _use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    config = require('plugins.appearance._telescope'),
    requires = {
      { 'nvim-lua/plenary.nvim' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make',
      },
      {
        'AckslD/nvim-neoclip.lua',
        config = require('plugins.appearance._neoclip'),
      }
    },
    after = { 'plenary.nvim' },
  }

  -- Comment
  _use {
    'numToStr/Comment.nvim',
    config = require('plugins.appearance._comment'),
  }
  -- indent line
  _use {
    'lukas-reineke/indent-blankline.nvim',
    config = require('plugins.appearance._indent-blankline'),
  }

  -- terminal
  _use {
    'akinsho/toggleterm.nvim',
    config = require('plugins.appearance._toggleterm'),
  }

  -- sidebar
  _use {
    'nvim-tree/nvim-tree.lua',
    config = require('plugins.appearance._nvim-tree'),
  }
  -- tab
  _use {
    'akinsho/bufferline.nvim',
    config = require('plugins.appearance._bufferline'),
    requires = {
      { 'nvim-tree/nvim-web-devicons', as = 'tree-web-devicons', },
    },
  }

  -- delete buffer without closing window
  _use {
    'famiu/bufdelete.nvim',
    config = require('plugins.appearance._bufdelete'),
  }

  -- statusbar
  _use {
    'nvim-lualine/lualine.nvim',
    config = require('plugins.appearance._lualine'),
    requires = {
      { 'kyazdani42/nvim-web-devicons', as = 'lualine-web-devicons', }
    }
  }

  -- gitsign
  _use {
    'lewis6991/gitsigns.nvim',
    tag = 'release',
    config = require('plugins.appearance._gitsigns'),
  }

  -- color theme
  _use {
    'ellisonleao/gruvbox.nvim',
    config = require('plugins.appearance._gruvbox'),
  }

end
