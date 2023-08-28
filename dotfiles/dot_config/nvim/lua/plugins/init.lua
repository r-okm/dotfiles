local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "vim-jp/vimdoc-ja" },
  { "yutkat/wb-only-current-line.nvim" },
  { "tommcdo/vim-exchange" },

  {
    "haya14busa/vim-asterisk",
    config = function()
      local keymap = require("utils.setKeymap").keymap
      keymap("nx", "*", "<Plug>(asterisk-gz*)")
    end,
  },

  {
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
  },

  {
    "unblevable/quick-scope",
    init = function()
      vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
      local set_hl = vim.api.nvim_set_hl
      set_hl(0, "QuickScopePrimary", { fg = "#afff5f", underline = true, nocombine = true })
      set_hl(0, "QuickScopeSecondary", { fg = "#5fffff", underline = true, nocombine = true })
    end,
  },

  {
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
  },

  {
    "rhysd/vim-operator-surround",
    dependencies = { "kana/vim-operator-user", "tpope/vim-repeat" },
    config = function()
      local keymap = require("utils.setKeymap").keymap
      keymap("nx", "sa", "<Plug>(operator-surround-append)")
      keymap("n", "sd", "<Plug>(operator-surround-delete)a")
      keymap("n", "sr", "<Plug>(operator-surround-replace)a")
      keymap("x", "sd", "<Plug>(operator-surround-delete)")
      keymap("x", "sr", "<Plug>(operator-surround-replace)")
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "hrsh7th/cmp-buffer",
        event = { "InsertEnter" },
        cond = function()
          return not vim.g.vscode
        end
      },
      {
        "hrsh7th/cmp-path",
        event = { "InsertEnter" },
        cond = function()
          return not vim.g.vscode
        end
      },
      {
        "hrsh7th/cmp-cmdline",
        event = { "InsertEnter", "CmdlineEnter" },
        cond = function()
          return not vim.g.vscode
        end
      },
    },
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        sources = cmp.config.sources({
          { name = "buffer" },
        }),
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        }
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  {
    "ellisonleao/gruvbox.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    event = "BufEnter",
    config = function()
      vim.o.background = "dark"
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
})
