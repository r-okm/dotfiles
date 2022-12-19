return function(use)
  local not_vscode = function()
    return vim.g.vscode == nil
  end

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = ('plugins.appearance._treesitter'),
    cond = not_vscode,
  }
  use {
    'windwp/nvim-autopairs',
    config = ('plugins.appearance._autopairs'),
    cond = not_vscode,
  }
  use {
    'RRethy/vim-illuminate',
    config = ('plugins.appearance._illuminate'),
    cond = not_vscode,
  }

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    config = ('plugins.appearance._telescope'),
    cond = not_vscode,
  }
  use {
    'nvim-lua/plenary.nvim',
    cond = not_vscode,
  }
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
    cond = not_vscode,
  }

  use {
    'AckslD/nvim-neoclip.lua',
    config = ('plugins.appearance._neoclip'),
    cond = not_vscode,
  }

  -- Comment
  use {
    'numToStr/Comment.nvim',
    config = ('plugins.appearance._comment'),
    cond = not_vscode,
  }
  -- indent line
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = ('plugins.appearance._indent-blankline'),
    cond = not_vscode,
  }

  -- terminal
  use {
    'akinsho/toggleterm.nvim',
    config = ('plugins.appearance._toggleterm'),
    cond = not_vscode,
  }

  -- sidebar
  use {
    'nvim-tree/nvim-tree.lua',
    config = ('plugins.appearance._nvim-tree'),
    cond = not_vscode,
  }
  -- tab
  use {
    'akinsho/bufferline.nvim',
    config = ('plugins.appearance._bufferline'),
    cond = not_vscode,
  }
  use {
    'nvim-tree/nvim-web-devicons',
    as = 'tree-web-devicons',
    cond = not_vscode,
  }

  -- delete buffer without closing window
  use {
    'famiu/bufdelete.nvim',
    config = ('plugins.appearance._bufdelete'),
    cond = not_vscode,
  }

  -- statusbar
  use {
    'nvim-lualine/lualine.nvim',
    config = ('plugins.appearance._lualine'),
    cond = not_vscode,
  }
  use { 'kyazdani42/nvim-web-devicons', as = 'lualine-web-devicons', opt = true }

  -- gitsign
  use {
    'lewis6991/gitsigns.nvim',
    tag = 'release',
    config = ('plugins.appearance._gitsigns'),
    cond = not_vscode,
  }

  -- color theme
  use {
    'ellisonleao/gruvbox.nvim',
    config = ('plugins.appearance._gruvbox'),
    cond = not_vscode,
  }

end
