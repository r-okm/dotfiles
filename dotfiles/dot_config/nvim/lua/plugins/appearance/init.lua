return function(use)
  local vscode = vim.g.vscode == 1

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = ('plugins.appearance._treesitter'),
    cond = vscode,
  }
  use {
    'windwp/nvim-autopairs',
    config = ('plugins.appearance._autopairs'),
    cond = vscode,
  }
  use {
    'RRethy/vim-illuminate',
    config = ('plugins.appearance._illuminate'),
    cond = vscode,
  }

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    config = ('plugins.appearance._telescope'),
    cond = vscode,
  }
  use {
    'nvim-lua/plenary.nvim',
    cond = vscode,
  }
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
    cond = vscode,
  }

  use {
    'AckslD/nvim-neoclip.lua',
    config = ('plugins.appearance._neoclip'),
    cond = vscode,
  }

  -- Comment
  use {
    'numToStr/Comment.nvim',
    config = ('plugins.appearance._comment'),
    cond = vscode,
  }
  -- indent line
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = ('plugins.appearance._indent-blankline'),
    cond = vscode,
  }

  -- terminal
  use {
    'akinsho/toggleterm.nvim',
    config = ('plugins.appearance._toggleterm'),
    cond = vscode,
  }

  -- sidebar
  use {
    'nvim-tree/nvim-tree.lua',
    config = ('plugins.appearance._nvim-tree'),
    cond = vscode,
  }
  -- tab
  use {
    'akinsho/bufferline.nvim',
    config = ('plugins.appearance._bufferline'),
    cond = vscode,
  }
  use {
    'nvim-tree/nvim-web-devicons',
    as = 'tree-web-devicons',
    cond = vscode,
  }

  -- delete buffer without closing window
  use {
    'famiu/bufdelete.nvim',
    config = ('plugins.appearance._bufdelete'),
    cond = vscode,
  }

  -- statusbar
  use {
    'nvim-lualine/lualine.nvim',
    config = ('plugins.appearance._lualine'),
    cond = vscode,
  }
  use { 'kyazdani42/nvim-web-devicons', as = 'lualine-web-devicons', opt = true }

  -- gitsign
  use {
    'lewis6991/gitsigns.nvim',
    tag = 'release',
    config = ('plugins.appearance._gitsigns'),
    cond = vscode,
  }

  -- color theme
  use {
    'ellisonleao/gruvbox.nvim',
    config = ('plugins.appearance._gruvbox'),
    cond = vscode,
  }

end
