local u_setKeymap = require("utils.setKeymap")
local u_buffer = require("utils.buffer")

local keymap = u_setKeymap.keymap
local getVisualSelection = u_buffer.getVisualSelection

local notVscode = not vim.g.vscode
local function telescope_buffer_dir()
  return vim.fn.expand("%:p:h")
end

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
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_disable_italic_comment = 1
      vim.g.gruvbox_material_diagnostic_text_highlight = 1
      vim.cmd([[colorscheme gruvbox-material]])
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    cond = notVscode,
    event = { "BufReadPost" },
    build = { ":TSUpdate" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "c", "c_sharp", "cpp", "css", "diff", "dockerfile", "git_config",
          "git_rebase", "gitattributes", "gitcommit", "gitignore", "html", "java", "javascript", "jq", "jsdoc", "json",
          "jsonc", "lua", "markdown", "markdown_inline", "sql", "terraform", "toml", "tsx",
          "typescript", "vim", "vimdoc",
        },
        highlight = {
          enable = true,
        },
      })
    end,
  },

  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring"
    },
    event = { "BufReadPost", "BufNewFile", },
    cond = notVscode,
    config = function()
      require("ts_context_commentstring").setup {
        enable_autocmd = false,
      }
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  {
    "RRethy/vim-illuminate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
    cond = notVscode,
    event = { "BufReadPost", "BufNewFile" },
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

      local scroll_down_float_window = function()
        if vim.api.nvim_eval('coc#float#has_scroll()') then
          vim.api.nvim_eval('coc#float#scroll(1)')
        end
      end

      local scroll_up_float_window = function()
        if vim.api.nvim_eval('coc#float#has_scroll()') then
          vim.api.nvim_eval('coc#float#scroll(0)')
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
      -- scroll float window
      keymap("n", "<C-n>", scroll_down_float_window)
      keymap("n", "<C-p>", scroll_up_float_window)
      -- symbol rename
      keymap("n", "gr", "<Plug>(coc-rename)")
      -- format
      keymap("n", "gf", "<Plug>(coc-format)")
      keymap("x", "gf", "<Plug>(coc-format-selected)")
      -- code action
      keymap("n", "ga", "<Plug>(coc-codeaction-cursor)")
      -- organize import
      keymap("n", "go", function()
        vim.fn.CocActionAsync('organizeImport')
      end)
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
          theme = "gruvbox-material",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "g:coc_status" },
          lualine_y = { "encoding", "filetype" },
          lualine_z = { "location" }
        },
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    version = "0.1.4",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cond = notVscode,
    keys = {
      { "<C-p>", mode = { "n" } },
      { "<C-g>", mode = { "n" } },
      { "<C-f>", mode = { "n" } },
    },
    init = function()
      local actions = require("telescope.actions")
      local telescope = require("telescope")

      telescope.setup {
        defaults = {
          mappings = {
            n = {
              ["q"] = actions.close
            }
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--line-number",
            "--column",
            "--only-matching",
            "--hidden",
            "--glob",
            "!**/.git/*",
            "--glob",
            "!**/node_modules/*",
            "--glob",
            "!**/package-lock.json",
          }
        },
        pickers = {
          find_files = {
            find_command = {
              "rg",
              "--color=never",
              "--files",
              "--hidden",
              "--no-ignore",
              "--glob",
              "!**/.git/*",
              "--glob",
              "!**/node_modules/*",
            },
          },
          grep_string = { initial_mode = "normal" },
        },
        extensions = {
          fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
          },
        },
      }
    end,
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.load_extension("fzy_native")
      telescope.load_extension("file_browser")

      keymap("n", "zp", builtin.find_files)
      keymap("n", "zf", builtin.live_grep)
      keymap("n", "#", builtin.grep_string)
      keymap("x", "#", function()
        local text = getVisualSelection()
        builtin.grep_string({ search = text })
      end)
      keymap("n", "<Space>e", function()
        telescope.extensions.file_browser.file_browser({
          hidden = {
            file_browser = true,
            folder_browser = true,
          },
          cwd = telescope_buffer_dir(),
          initial_mode = "normal",
        })
      end)
    end
  },

  {
    "akinsho/bufferline.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    cond = notVscode,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      keymap("n", "<C-l>", ":BufferLineCycleNext<CR>")
      keymap("n", "<C-h>", ":BufferLineCyclePrev<CR>")
      keymap("n", "L", ":BufferLineMoveNext<CR>")
      keymap("n", "H", ":BufferLineMovePrev<CR>")

      local bufferline = require("bufferline")
      bufferline.setup({
        options = {
          middle_mouse_command = "Bdelete %d",
          diagnostics = "coc",
          separator_style = { "│", "│" },
          show_buffer_close_icons = false,
          indicator = {
            icon = "",
            style = "icon",
          },
        },
      })
    end,
  },

  {
    "famiu/bufdelete.nvim",
    cond = notVscode,
    keys = {
      { "<Space>w", mode = { "n" } }
    },
    cmd = { "Bdelete", "Bwipeout" },
    config = function()
      keymap("n", "<Space>w", ":<C-u>Bdelete<CR>")
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    cond = notVscode,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("gitsigns").setup()
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    cond = notVscode,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ibl").setup({
        indent = {
          char = "▏"
        },
        scope = {
          enabled = false,
          show_start = false,
          show_end = false,
        }
      })
    end,
  },

}
