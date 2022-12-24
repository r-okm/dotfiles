return function(use)
  use { 'vim-jp/vimdoc-ja' }

  use {
    'haya14busa/vim-asterisk',
    config = function()
      local keymap = require('utils.setKeymap').keymap
      keymap('nx', '*', '<Plug>(asterisk-gz*)')
    end,
  }

  use {
    'ggandor/flit.nvim',
    config = function()
      require('flit').setup {
        multiline = false
      }
    end,
    requires = {
      {
        'ggandor/leap.nvim',
        config = function()
          local leap = require('leap')
          leap.opts.safe_labels = {}
          leap.opts.labels = {
            "s", "f", "n",
            "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
            "u", "y", "v", "r", "g", "t", "c", "x", "/", "z"
          }
          local keymap = require('utils.setKeymap').keymap

          keymap('nxo', 'm', function()
            leap.leap { target_windows = { vim.fn.win_getid() } }
          end)
        end,
      }
    }
  }

  use {
    'gbprod/substitute.nvim',
    config = function()
      local keymap = require('utils.setKeymap').keymap
      keymap('nx', ',', function() require("substitute").operator() end)
    end,
  }

  use {
    'osyo-manga/vim-textobj-multiblock',
    requires = { 'kana/vim-textobj-user' },
    config = function()
      vim.g.textobj_multiblock_blocks = {
        { "(", ")" },
        { "[", "]" },
        { "{", "}" },
        { '<', '>' },
        { '"', '"', 1 },
        { "'", "'", 1 },
        { "`", "`", 1 },
      }

      local keymap = require('utils.setKeymap').keymap
      keymap('ox', 'ab', '<Plug>(textobj-multiblock-a)')
      keymap('ox', 'ib', '<Plug>(textobj-multiblock-i)')
    end,
  }

  use {
    'rhysd/vim-operator-surround',
    requires = { 'kana/vim-operator-user', 'tpope/vim-repeat' },
    config = function()
      local keymap = require('utils.setKeymap').keymap
      keymap('nx', 'sa', '<Plug>(operator-surround-append)')
      keymap('n', 'sd', '<Plug>(operator-surround-delete)a')
      keymap('n', 'sr', '<Plug>(operator-surround-replace)a')
      keymap('x', 'sd', '<Plug>(operator-surround-delete)')
      keymap('x', 'sr', '<Plug>(operator-surround-replace)')
      keymap('n', 'sdd', '<Plug>(operator-surround-delete)<Plug>(textobj-multiblock-a)')
      keymap('n', 'srr', '<Plug>(operator-surround-replace)<Plug>(textobj-multiblock-a)')
    end,
  }
end
