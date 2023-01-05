return function()
  require("mason").setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  })

  local mlc = require("mason-lspconfig")
  mlc.setup({
    ensure_installed = require("lsp.servers").lsp,
  })

  mlc.setup_handlers({ function(server)
    local opts = require(string.format("lsp.servers.%s", server))

    if server == "tsserver" then
      require("typescript").setup({
        server = opts
      })
    else
      require("lspconfig")[server].setup(opts)
    end
  end
  })

  vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
  })
end
