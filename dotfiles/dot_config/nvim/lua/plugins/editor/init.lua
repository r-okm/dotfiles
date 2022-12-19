return function(use)
  use { 'vim-jp/vimdoc-ja' }
  use {
    'haya14busa/vim-asterisk',
    config = require('plugins.editor._asterisk'),
  }
  use {
    'ggandor/flit.nvim',
    config = require('plugins.editor._flit'),
    requires = {
      { 'ggandor/leap.nvim', config = require('plugins.editor._leap') }
    }
  }
  use {
    'gbprod/substitute.nvim',
    config = require('plugins.editor._substitute'),
  }
  use {
    'osyo-manga/vim-textobj-multiblock',
    config = require('plugins.editor._textobj-multiblock'),
    requires = { 'kana/vim-textobj-user' },
  }
  use {
    'rhysd/vim-operator-surround',
    config = require('plugins.editor._operator-surround'),
    requires = { 'kana/vim-operator-user', 'tpope/vim-repeat' },
  }
end
