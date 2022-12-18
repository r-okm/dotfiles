local opts = {
  on_attach_extra = function(client, _)
    client.server_capabilities.documentFormattingProvider = false
  end
}

return opts
