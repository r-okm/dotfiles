return function(use)
  local not_vscode = function()
    return vim.g.vscode == nil
  end

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    event = { 'BufRead', 'BufNewFile' },
    cond = not_vscode(),
    config = require('plugins.appearance._treesitter'),
  }
  use {
    'windwp/nvim-autopairs',
    event = { 'InsertEnter' },
    requires = {
      { 'nvim-treesitter/nvim-treesitter', opt = true },
      { 'hrsh7th/nvim-cmp', opt = true },
    },
    wants = { 'nvim-treesitter', 'nvim-cmp' },
    cond = not_vscode(),
    config = require('plugins.appearance._autopairs'),
  }
  use {
    'RRethy/vim-illuminate',
    event = { 'BufRead', 'BufNewFile' },
    requires = {
      { 'nvim-treesitter/nvim-treesitter', opt = true },
    },
    wants = { 'nvim-treesitter' },
    cond = not_vscode(),
    config = require('plugins.appearance._illuminate'),
  }

  -- telescope
  use {
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
      if vim.g.vscode then
        return
      end

      local telescope = require('telescope')
      local builtin = require('telescope.builtin')

      telescope.load_extension('fzf')
      telescope.load_extension('neoclip')

      telescope.project_files = function()
        local ok = pcall(builtin.git_files)
        if not ok then builtin.find_files() end
      end

      local keymap = require('utils.setKeymap').keymap
      keymap('n', '<C-p>', telescope.project_files)
      keymap('n', '<C-g>', builtin.git_status)
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
            case_mode = 'smart_case',
          },
        },
      }
    end,
  }
  use {
    'aznhe21/actions-preview.nvim',
    event = { 'BufRead', 'BufNewFile', },
    config = function()
      require('actions-preview').setup {
        telescope = {
          sorting_strategy = 'ascending',
          layout_strategy = 'vertical',
          layout_config = {
            width = 0.8,
            height = 0.9,
            prompt_position = 'top',
            preview_cutoff = 20,
            preview_height = function(_, _, max_lines)
              return max_lines - 15
            end,
          },
        },
      }
    end,
  }

  -- Comment
  use {
    'numToStr/Comment.nvim',
    event = { 'BufRead', 'BufNewFile', },
    cond = not_vscode(),
    config = function()
      require('Comment').setup()
    end,
  }
  -- indent line
  use {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufRead', 'BufNewFile' },
    cond = not_vscode(),
    config = require('plugins.appearance._indent-blankline'),
  }

  -- color
  use {
    'norcalli/nvim-colorizer.lua',
    event = { 'BufRead', 'BufNewFile' },
    cond = not_vscode(),
    config = function()
      local css_opts = {
        rgb_fn = true, names = true
      }
      require('colorizer').setup({
        '*';
        css = css_opts,
        scss = css_opts,
        stylus = css_opts,
      }, { names = false })
    end
  }

  -- terminal
  use {
    'akinsho/toggleterm.nvim',
    config = require('plugins.appearance._toggleterm'),
  }

  -- filer
  use {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeFindFile' },
    requires = {
      { 'nvim-tree/nvim-web-devicons', opt = true },
    },
    wants = { 'nvim-web-devicons' },
    setup = function()
      if vim.g.vscode then
        return
      end

      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      local keymap = require('utils.setKeymap').keymap
      keymap('n', '<Space>e', ':<C-u>NvimTreeFindFile<Cr>')
    end,
    config = function()
      require('nvim-tree').setup {
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
  use {
    'akinsho/bufferline.nvim',
    event = { 'BufRead', 'BufNewFile' },
    requires = {
      { 'nvim-tree/nvim-web-devicons', opt = true },
    },
    wants = { 'nvim-web-devicons' },
    cond = not_vscode(),
    config = function()
      require('bufferline').setup()
    end,
  }

  -- delete buffer without closing window
  use {
    'famiu/bufdelete.nvim',
    cmd = {
      'Bdelete',
      'Bwipeout',
    },
    setup = function()
      if vim.g.vscode then
        return
      end

      local keymap = require('utils.setKeymap').keymap
      keymap('n', '<Space>w', ':<C-u>Bwipeout<CR>')
    end,
  }

  -- statusbar
  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      { 'kyazdani42/nvim-web-devicons', as = 'lualine-web-devicons' }
    },
    config = function()
      require('lualine').setup()
    end,
    cond = not_vscode(),
  }

  -- gitsign
  use {
    'lewis6991/gitsigns.nvim',
    event = { 'BufRead', 'BufNewFile' },
    cond = not_vscode(),
    config = function()
      require('gitsigns').setup()
    end,
  }

  -- color theme
  use {
    'ellisonleao/gruvbox.nvim',
    cond = not_vscode(),
    config = require('plugins.appearance._gruvbox'),
  }

end
