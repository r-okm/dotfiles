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
    event = 'BufRead',
    run = ':TSUpdate',
    config = require('plugins.appearance._treesitter'),
  }
  _use {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = require('plugins.appearance._autopairs'),
    requires = {
      { 'nvim-treesitter/nvim-treesitter', opt = true },
      { 'hrsh7th/nvim-cmp', opt = true },
    },
    wants = { 'nvim-treesitter', 'nvim-cmp' },
  }
  _use {
    'RRethy/vim-illuminate',
    event = 'BufRead',
    config = require('plugins.appearance._illuminate'),
    requires = {
      { 'nvim-treesitter/nvim-treesitter', opt = true },
    },
    wants = { 'nvim-treesitter' },
  }

  -- telescope
  _use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    module = 'telescope',
    requires = {
      { 'nvim-lua/plenary.nvim', opt = true, },
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', opt = true, },
      { 'AckslD/nvim-neoclip.lua', config = require('plugins.appearance._neoclip'), opt = true, },
    },
    wants = {
      'plenary.nvim',
      'telescope-fzf-native.nvim',
      'nvim-neoclip.lua'
    },
    setup = function()
      local telescope = require('telescope')
      telescope.load_extension('fzf')
      telescope.load_extension('neoclip')

      local builtin = require('telescope.builtin')
      local keymap = require('utils.setKeymap').keymap
      keymap('n', '<C-p>', builtin.git_files)
      keymap('n', '<C-o>', builtin.git_status)
      keymap('n', '<C-f>', builtin.live_grep)
      keymap('n', 'gp', ':<C-u>Telescope neoclip<CR>')
    end,
    config = function()
      require('telescope').setup {
        pickers = {
          find_files = {
            hidden = true,
          },
          git_files = {
            show_untracked = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }
    end,
  }

  -- Comment
  _use {
    'numToStr/Comment.nvim',
    module = 'Comment',
    setup = function()
      require('Comment').setup()
    end,
  }
  -- indent line
  _use {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufRead',
    config = require('plugins.appearance._indent-blankline'),
  }

  -- terminal
  _use {
    'akinsho/toggleterm.nvim',
    fn = 'LazygitToggle',
    config = require('plugins.appearance._toggleterm'),
  }

  -- sidebar
  _use {
    'nvim-tree/nvim-tree.lua',
    cmd = {
      'NvimTreeFindFile',
      'NvimTreeCollapse',
    },
    setup = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      local keymap = require('utils.setKeymap').keymap
      keymap('n', '<Leader>e', ':NvimTreeFindFile<Cr>')
      keymap('n', '<Leader>c', ':NvimTreeCollapse<Cr>')
    end,
    config = function()
      require("nvim-tree").setup {
        view = {
          mappings = {
            list = {
              { key = 'h', action = 'close_node' },
              { key = 'l', action = 'preview' },
              { key = 'v', action = 'vsplit' },
            },
          },
          float = {
            enable = true,
            open_win_config = {
              width = 50,
              height = 80,
            }
          },
        },
        actions = {
          open_file = {
            quit_on_open = true
          },
        },
      }
    end,
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
    module = 'bufdelete',
    setup = require('plugins.appearance._bufdelete'),
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
    event = 'BufRead',
    config = require('plugins.appearance._gitsigns'),
  }

  -- color theme
  _use {
    'ellisonleao/gruvbox.nvim',
    config = require('plugins.appearance._gruvbox'),
  }

end
