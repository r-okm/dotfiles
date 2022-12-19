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
    config = ('plugins.appearance._treesitter'),
  }
  _use {
    'windwp/nvim-autopairs',
    config = ('plugins.appearance._autopairs'),
  }
  _use {
    'RRethy/vim-illuminate',
    config = ('plugins.appearance._illuminate'),
  }

  -- telescope
  _use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    config = ('plugins.appearance._telescope'),
  }
  _use {
    'nvim-lua/plenary.nvim',
  }
  _use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
  }

  _use {
    'AckslD/nvim-neoclip.lua',
    config = ('plugins.appearance._neoclip'),
  }

  -- Comment
  _use {
    'numToStr/Comment.nvim',
    config = ('plugins.appearance._comment'),
  }
  -- indent line
  _use {
    'lukas-reineke/indent-blankline.nvim',
    config = ('plugins.appearance._indent-blankline'),
  }

  -- terminal
  _use {
    'akinsho/toggleterm.nvim',
    config = ('plugins.appearance._toggleterm'),
  }

  -- sidebar
  _use {
    'nvim-tree/nvim-tree.lua',
    config = ('plugins.appearance._nvim-tree'),
  }
  -- tab
  _use {
    'akinsho/bufferline.nvim',
    config = ('plugins.appearance._bufferline'),
  }
  _use {
    'nvim-tree/nvim-web-devicons',
    as = 'tree-web-devicons',
  }

  -- delete buffer without closing window
  _use {
    'famiu/bufdelete.nvim',
    config = ('plugins.appearance._bufdelete'),
  }

  -- statusbar
  _use {
    'nvim-lualine/lualine.nvim',
    config = ('plugins.appearance._lualine'),
  }
  _use { 'kyazdani42/nvim-web-devicons', as = 'lualine-web-devicons', opt = true }

  -- gitsign
  _use {
    'lewis6991/gitsigns.nvim',
    tag = 'release',
    config = ('plugins.appearance._gitsigns'),
  }

  -- color theme
  _use {
    'ellisonleao/gruvbox.nvim',
    config = ('plugins.appearance._gruvbox'),
  }

end
