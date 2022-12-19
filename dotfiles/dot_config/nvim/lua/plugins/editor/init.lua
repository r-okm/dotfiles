return function(use)
  use { 'vim-jp/vimdoc-ja' }
  use { 'tpope/vim-repeat' }
  use { 'haya14busa/vim-asterisk', config = require('plugins.editor._asterisk') }
  use { 'ggandor/leap.nvim', config = require('plugins.editor._leap') }
  use { 'ggandor/flit.nvim', config = require('plugins.editor._flit') }
  use { 'kana/vim-textobj-user' }
  use { 'osyo-manga/vim-textobj-multiblock', config = require('plugins.editor._textobj-multiblock') }
  use { 'kana/vim-operator-user' }
  use { 'gbprod/substitute.nvim', config = require('plugins.editor._substitute') }
  use { 'rhysd/vim-operator-surround', config = require('plugins.editor._operator-surround') }
end
