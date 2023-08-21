return function(use)
  use { "vim-jp/vimdoc-ja" }
  use { "yutkat/wb-only-current-line.nvim" }
  use { "tommcdo/vim-exchange" }

  use {
    "haya14busa/vim-asterisk",
    config = function()
      local keymap = require("utils.setKeymap").keymap
      keymap("nx", "*", "<Plug>(asterisk-gz*)")
    end,
  }

  use {
    "ggandor/leap.nvim",
    config = function()
      local leap = require("leap")
      leap.opts.safe_labels = {}
      leap.opts.labels = {
        "s", "f", "n",
        "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
        "u", "y", "v", "r", "g", "t", "c", "x", "/", "z"
      }
      local keymap = require("utils.setKeymap").keymap

      keymap("nxo", "m", function()
        leap.leap { target_windows = { vim.fn.win_getid() } }
      end)
    end,
  }

  use {
    "unblevable/quick-scope",
    config = function()
      vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
      local set_hl = vim.api.nvim_set_hl
      set_hl(0, "QuickScopePrimary", { fg = "#afff5f", underline = true, nocombine = true })
      set_hl(0, "QuickScopeSecondary", { fg = "#5fffff", underline = true, nocombine = true })
    end,
  }

  use {
    "gbprod/substitute.nvim",
    config = function()
      local keymap = require("utils.setKeymap").keymap
      local substitute = require("substitute")
      substitute.setup({
        highlight_substituted_text = {
          enabled = false,
        },
      })
      keymap("nx", ",", function() substitute.operator() end)
    end,
  }

  use {
    "rhysd/vim-operator-surround",
    requires = { "kana/vim-operator-user", "tpope/vim-repeat" },
    config = function()
      local keymap = require("utils.setKeymap").keymap
      keymap("nx", "sa", "<Plug>(operator-surround-append)")
      keymap("n", "sd", "<Plug>(operator-surround-delete)a")
      keymap("n", "sr", "<Plug>(operator-surround-replace)a")
      keymap("x", "sd", "<Plug>(operator-surround-delete)")
      keymap("x", "sr", "<Plug>(operator-surround-replace)")
    end,
  }
end
