return function()
  local keymap = require('utils.setKeymap').keymap
  keymap('n', '<C-l>', ':BufferLineCycleNext<CR>')
  keymap('n', '<C-h>', ':BufferLineCyclePrev<CR>')
  keymap('n', 'L', ':BufferLineMoveNext<CR>')
  keymap('n', 'H', ':BufferLineMovePrev<CR>')

  require('bufferline').setup({
    options = {
      middle_mouse_command = 'Bdelete %d',
      diagnostics = 'nvim_lsp',
      separator_style = 'padded_slant',
      offsets = {
        {
          filetype = "NvimTree",
          text = "[File Explorer]",
          text_align = "center",
          separator = true,
        }
      },
      show_buffer_close_icons = false,
      custom_areas = {
        right = function()
          local result = {}
          local seve = vim.diagnostic.severity
          local error = #vim.diagnostic.get(0, { severity = seve.ERROR })
          local warning = #vim.diagnostic.get(0, { severity = seve.WARN })
          local info = #vim.diagnostic.get(0, { severity = seve.INFO })
          local hint = #vim.diagnostic.get(0, { severity = seve.HINT })

          if error ~= 0 then
            table.insert(result, { text = "  " .. error, fg = "#EC5241" })
          end

          if warning ~= 0 then
            table.insert(result, { text = "  " .. warning, fg = "#EFB839" })
          end

          if hint ~= 0 then
            table.insert(result, { text = "  " .. hint, fg = "#A3BA5E" })
          end

          if info ~= 0 then
            table.insert(result, { text = "  " .. info, fg = "#7EA9A7" })
          end
          return result
        end,
      },
    }
  })
end
