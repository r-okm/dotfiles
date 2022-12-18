local opts = {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      },
    },
  },
  on_attach_extra = function(_, bufnr)
    local setAutocmd = require('utils.setAutcmdFmtOnSaveToBuffer')
    setAutocmd(bufnr)
  end
}

return opts
