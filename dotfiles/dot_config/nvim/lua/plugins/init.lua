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
      'hrsh7th/nvim-cmp',
      config = require('plugins._nvim-cmp'),
    }
    use { 'hrsh7th/cmp-nvim-lsp' }
    use { 'hrsh7th/vim-vsnip' }
    use { 'hrsh7th/cmp-buffer' }
    use { 'hrsh7th/cmp-path' }
    use { 'hrsh7th/cmp-cmdline' }

    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      event = { 'BufRead', 'BufNewFile' },
      cmd = {
        "TSInstall",
        "TSInstallInfo",
        "TSInstallSync",
        "TSUninstall",
        "TSUpdate",
        "TSUpdateSync",
        "TSDisableAll",
        "TSEnableAll",
      },
      config = require('plugins._treesitter'),
    }

    use {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.0',
      config = require('plugins._telescope'),
    }
    use { 'nvim-lua/plenary.nvim' }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    use {
      'numToStr/Comment.nvim',
      config = require('plugins._comment')
    }

    use {
      'nvim-tree/nvim-tree.lua',
      config = require('plugins._nvim-tree')
    }
    use {
      'akinsho/bufferline.nvim',
      config = require('plugins._bufferline')
    }
    use { 'nvim-tree/nvim-web-devicons', as = 'tree-web-devicons' }

    use {
      'nvim-lualine/lualine.nvim',
      config = require('plugins._lualine')
    }
    use { 'kyazdani42/nvim-web-devicons', as = 'lualine-web-devicons', opt = true }

    use {
      'ellisonleao/gruvbox.nvim',
      config = require('plugins._gruvbox')
    }
  end
end)
