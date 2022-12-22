return {
  fidget = {
    config = function()
      require('fidget').setup()
    end
  },

  lspconfig = {
    config = function()
      local lsp = require('lspconfig')
      local mason = require('mason')
      local mlc = require('mason-lspconfig')
      local servers = require('plugins.lsp.servers')

      mason.setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })

      mlc.setup({
        ensure_installed = servers.list.lsp,
      })

      mlc.setup_handlers({ function(server)
        local opts = servers.configs[server]
        opts.capabilities = require('cmp_nvim_lsp').default_capabilities()
        opts.on_attach = function(client, bufnr)
          servers.attach_handlers['common'](client, bufnr)
          servers.attach_handlers[server](client, bufnr)
        end

        if server == 'tsserver' then
          require('typescript').setup({
            server = opts
          })
        else
          lsp[server].setup(opts)
        end
      end
      })

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
      )
    end,
  },

  null_ls = {
    config = function()
      local mnl = require('mason-null-ls')
      local nls = require('null-ls')
      local servers = require('plugins.lsp.servers')

      mnl.setup({
        ensure_installed = servers.list.null_ls,
      })
      nls.setup {
        sources = {
          nls.builtins.formatting.prettierd.with {
            prefer_local = 'node_modules/.bin',
          },
          require('typescript.extensions.null-ls.code-actions'),
        },
        on_attach = function(client, bufnr)
          servers.attach_handlers['common'](client, bufnr)
        end
      }
    end
  }
}
