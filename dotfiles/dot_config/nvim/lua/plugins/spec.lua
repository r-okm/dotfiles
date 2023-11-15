local utils = require("utils.setKeymap")
local keymap = utils.keymap

local notVscode = not vim.g.vscode

return {
  -- keys
  {
    "unblevable/quick-scope",
    keys = {
      { "f", mode = { "n", "x", "o" } },
      { "t", mode = { "n", "x", "o" } },
      { "F", mode = { "n", "x", "o" } },
      { "T", mode = { "n", "x", "o" } },
    },
    init = function()
      vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
      local set_hl = vim.api.nvim_set_hl
      set_hl(0, "QuickScopePrimary", { fg = "#afff5f", underline = true, nocombine = true })
      set_hl(0, "QuickScopeSecondary", { fg = "#5fffff", underline = true, nocombine = true })
    end,
  },

  {
    "yutkat/wb-only-current-line.nvim",
    keys = {
      { "w", mode = { "n", "x", "o" } },
      { "b", mode = { "n", "x", "o" } },
    },
  },

  {
    "tommcdo/vim-exchange",
    keys = { "cx" },
  },

  {
    "haya14busa/vim-asterisk",
    keys = {
      { "*", mode = { "n", "x" } },
    },
    config = function()
      keymap("nx", "*", "<Plug>(asterisk-gz*)")
    end,
  },

  {
    "ggandor/leap.nvim",
    keys = {
      { "m", mode = { "n", "x", "o" } },
    },
    config = function()
      local leap = require("leap")
      leap.opts.safe_labels = {}
      leap.opts.labels = {
        "s", "f", "n",
        "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
        "u", "y", "v", "r", "g", "t", "c", "x", "/", "z"
      }
      keymap("nxo", "m", function()
        leap.leap { target_windows = { vim.fn.win_getid() } }
      end)
    end,
  },

  {
    "gbprod/substitute.nvim",
    keys = {
      { ",", mode = { "n", "x" } },
    },
    config = function()
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
    keys = {
      { "sa", mode = { "n", "x" } },
      { "sd", mode = { "n", "x" } },
      { "sr", mode = { "n", "x" } },
    },
    config = function()
      keymap("nx", "sa", "<Plug>(operator-surround-append)")
      keymap("n", "sd", "<Plug>(operator-surround-delete)a")
      keymap("n", "sr", "<Plug>(operator-surround-replace)a")
      keymap("x", "sd", "<Plug>(operator-surround-delete)")
      keymap("x", "sr", "<Plug>(operator-surround-replace)")
    end,
  },

  -- event
  {
    "vim-jp/vimdoc-ja",
    event = { "CmdlineEnter" },
  },

  -- not vscode
  {
    "sainnhe/gruvbox-material",
    cond = notVscode,
    config = function()
      vim.o.background = "dark"
      vim.g.gruvbox_material_background = "hard"
      vim.cmd([[colorscheme gruvbox-material]])
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    cond = notVscode,
    event = { "BufReadPre" },
    build = { ":TSUpdate" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "c", "c_sharp", "cpp", "css", "diff", "dockerfile", "git_config",
          "git_rebase", "gitattributes", "gitcommit", "gitignore", "html", "java", "javascript", "jq", "jsdoc", "json",
          "jsonc", "lua", "markdown", "markdown_inline", "sql", "terraform", "toml", "tsx",
          "typescript", "vim", "vimdoc", "vue", "yaml",
        },
        highlight = {
          enable = true,
        },
      })
    end,
  },

  {
    "neoclide/coc.nvim",
    cond = notVscode,
    branch = "release",
    config = function()
      local show_docs = function()
        local cw = vim.fn.expand('<cword>')
        if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
          vim.api.nvim_command('h ' .. cw)
        elseif vim.api.nvim_eval('coc#rpc#ready()') then
          vim.fn.CocActionAsync('doHover')
        else
          vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
        end
      end

      -- completion
      keymap("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"]],
        { expr = true })
      keymap("i", "<C-Space>", [[coc#refresh()]], { expr = true })
      -- diagnostic
      keymap("n", "g.", "<Plug>(coc-diagnostic-next)")
      keymap("n", "g,", "<Plug>(coc-diagnostic-prev)")
      -- code navigation
      keymap("n", "gd", "<Plug>(coc-definition)")
      keymap("n", "gD", "<Plug>(coc-implementation)")
      -- hover code action
      keymap("n", "K", show_docs)
      -- symbol rename
      keymap("n", "gn", "<Plug>(coc-rename)")
      -- format
      keymap("n", "gf", "<Plug>(coc-format)")
      keymap("x", "gf", "<Plug>(coc-format-selected)")
      -- code action
      keymap("n", "ga", "<Plug>(coc-codeaction-cursor)")
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    cond = notVscode,
    event = { "CmdlineEnter" },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
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
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    cond = notVscode,
    config = function()
      require("lualine").setup({
        options = {
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
      })
    end,
  },

}