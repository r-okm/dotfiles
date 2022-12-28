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

  local function get_icon(diagnostic)
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      return ""
    end
    if diagnostic.severity == vim.diagnostic.severity.WARN then
      return ""
    end
    if diagnostic.severity == vim.diagnostic.severity.HINT then
      return ""
    end
    if diagnostic.severity == vim.diagnostic.severity.INFO then
      return ""
    end
  end

  vim.diagnostic.config({
    virtual_text = {
      severity = { min = vim.diagnostic.severity.WARN },
      spacing = 3,
      prefix = "",
      format = function(diagnostic)
        return string.format("%s %s: %s", get_icon(diagnostic), diagnostic.source, diagnostic.code)
      end,
    },
    float = {
      format = function(diagnostic)
        return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
      end,
    },
    severity_sort = true,
  })
end
