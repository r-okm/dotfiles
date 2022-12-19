return function()
  local set_hl = vim.api.nvim_set_hl
  local bg_color = '#4C566A'

  set_hl(0, 'IlluminatedWordText', { bg = bg_color })
  set_hl(0, 'IlluminatedWordRead', { bg = bg_color })
  set_hl(0, 'IlluminatedWordWrite', { bg = bg_color })
end
