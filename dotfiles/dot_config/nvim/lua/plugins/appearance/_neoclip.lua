return function()
  require('neoclip').setup {
    history = 30,
    keys = {
      telescope = {
        i = {
          paste = '<CR>',
        },
        n = {
          paste = '<CR>',
        },
      },
    },
  }
end
