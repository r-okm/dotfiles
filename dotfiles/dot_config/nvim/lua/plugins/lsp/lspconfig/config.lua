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
  -- mlc.setup({
  --   ensure_installed = require("lsp.servers").lsp,
  -- })

  mlc.setup_handlers({
    function(server)
      local opts = require(string.format("lsp.servers.%s", server))
      require("lspconfig")[server].setup(opts)
    end,
    ["tsserver"] = function(server)
      local opts = require(string.format("lsp.servers.%s", server))
      require("typescript").setup({
        server = opts
      })
    end,
    ["jdtls"] = function() end
  })

  vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
  })
end
