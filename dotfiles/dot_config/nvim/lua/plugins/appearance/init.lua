return function(use)
  -- treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    event = { "BufRead", "BufNewFile" },
    cond = function()
      return not vim.g.vscode
    end,
    config = require("plugins.appearance.treesitter.config"),
  }
  use {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    wants = { "nvim-treesitter", "nvim-cmp" },
    cond = function()
      return not vim.g.vscode
    end,
    config = require("plugins.appearance.autopairs.config"),
  }
  use {
    "RRethy/vim-illuminate",
    event = { "BufRead", "BufNewFile" },
    wants = { "nvim-treesitter" },
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      local set_hl = vim.api.nvim_set_hl
      local bg_color = "#425259"

      set_hl(0, "IlluminatedWordText", { bg = bg_color })
      set_hl(0, "IlluminatedWordRead", { bg = bg_color })
      set_hl(0, "IlluminatedWordWrite", { bg = bg_color })
    end,
  }

  -- telescope
  use {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.0",
    module = "telescope",
    requires = {
      { "nvim-lua/plenary.nvim", opt = true, },
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make", opt = true, },
      { "AckslD/nvim-neoclip.lua", config = require("plugins.appearance.neoclip.config"), opt = true, },
      { "natecraddock/workspaces.nvim", config = require("plugins.appearance.workspaces.config"), opt = true, },
    },
    wants = {
      "plenary.nvim",
      "telescope-fzf-native.nvim",
      "nvim-neoclip.lua",
      "workspaces.nvim",
    },
    cond = function()
      return not vim.g.vscode
    end,
    setup = require("plugins.appearance.telescope.setup"),
    config = require("plugins.appearance.telescope.config"),
  }
  use {
    "aznhe21/actions-preview.nvim",
    event = { "BufRead", "BufNewFile", },
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      require("actions-preview").setup {
        telescope = {
          initial_mode = "normal",
          defaults = {
            mappings = {
              n = {
                ["q"] = require("telescope.actions").close
              }
            }
          },
          sorting_strategy = "ascending",
          layout_strategy = "vertical",
          layout_config = {
            width = 0.8,
            height = 0.9,
            prompt_position = "top",
            preview_cutoff = 20,
            preview_height = function(_, _, max_lines)
              return max_lines - 15
            end,
          },
        },
      }
    end,
  }

  -- trouble
  use {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    requires = {
      { "kyazdani42/nvim-web-devicons", as = "lualine-web-devicons", opt = true }
    },
    wants = { "lualine-web-devicons" },
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      require("trouble").setup {
        height = 7,
      }
    end,
  }

  -- file tree
  use {
    "nvim-tree/nvim-tree.lua",
    requires = {
      { "nvim-tree/nvim-web-devicons", opt = true },
    },
    wants = { "nvim-web-devicons" },
    cmd = { "NvimTreeOpen", "NvimTreeFindFile" },
    cond = function()
      return not vim.g.vscode
    end,
    config = require("plugins.appearance.nvim-tree.config"),
  }

  -- Comment
  use {
    "numToStr/Comment.nvim",
    event = { "BufRead", "BufNewFile", },
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      require("Comment").setup()
    end,
  }
  -- indent line
  use {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufRead", "BufNewFile" },
    cond = function()
      return not vim.g.vscode
    end,
    config = require("plugins.appearance.indent-blankline.config"),
  }

  -- color
  use {
    "norcalli/nvim-colorizer.lua",
    event = { "BufRead", "BufNewFile" },
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      local css_opts = {
        rgb_fn = true, names = true
      }
      require("colorizer").setup({
        "*";
        css = css_opts,
        scss = css_opts,
        stylus = css_opts,
      }, { names = false })
    end
  }

  -- terminal
  use {
    "akinsho/toggleterm.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    config = require("plugins.appearance.toggleterm.config"),
  }

  -- tab
  use {
    "akinsho/bufferline.nvim",
    event = { "BufRead", "BufNewFile" },
    requires = {
      { "nvim-tree/nvim-web-devicons", opt = true },
    },
    wants = { "nvim-web-devicons" },
    cond = function()
      return not vim.g.vscode
    end,
    config = require("plugins.appearance.bufferline.config"),
  }

  -- delete buffer without closing window
  use {
    "famiu/bufdelete.nvim",
    cmd = {
      "Bdelete",
      "Bwipeout",
    },
    setup = function()
      if vim.g.vscode then
        return
      end

      local keymap = require("utils.setKeymap").keymap
      keymap("n", "<Space>w", ":<C-u>Bdelete<CR>")
    end,
  }

  -- statusbar
  use {
    "nvim-lualine/lualine.nvim",
    requires = {
      { "kyazdani42/nvim-web-devicons", as = "lualine-web-devicons", opt = true }
    },
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      require("lualine").setup()
    end,
  }

  -- gitsign
  use {
    "lewis6991/gitsigns.nvim",
    event = { "BufRead", "BufNewFile" },
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      require("gitsigns").setup()
    end,
  }

  -- color theme
  use {
    "ellisonleao/gruvbox.nvim",
    cond = function()
      return not vim.g.vscode
    end,
    config = function()
      require("gruvbox").setup({
        italic = false,
        overrides = {
          Search = { fg = "#e3c47b" },
        },
      })
      vim.o.background = "dark"
      vim.cmd([[colorscheme gruvbox]])
    end,
  }
  -- use {
  --   "rebelot/kanagawa.nvim",
  --   cond = function()
  --     return not vim.g.vscode
  --   end,
  --   config = function()
  --     require("kanagawa").setup({
  --       commentStyle = { italic = false },
  --       keywordStyle = { italic = false },
  --       variablebuiltinStyle = { italic = false },
  --       overrides = {
  --         Visual = { bg = "#59594e" },
  --       },
  --     })
  --     vim.cmd("colorscheme kanagawa")
  --   end,
  -- }

end
