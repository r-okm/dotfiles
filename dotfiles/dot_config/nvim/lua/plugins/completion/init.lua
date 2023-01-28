return function(use)
  -- cmp
  use {
    "hrsh7th/nvim-cmp",
    module = "cmp",
    requires = {
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
  }

end
