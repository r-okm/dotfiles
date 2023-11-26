local keymap = require("utils.setKeymap").keymap

return {
  "neoclide/coc.nvim",
  branch = "release",
  event = { "BufReadPost", "BufNewFile", },
  config = function()
    local show_docs = function()
      local cw = vim.fn.expand('<cword>')
      if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
      elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
      else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
      end
    end

    local scroll_down_float_window = function()
      if vim.api.nvim_eval('coc#float#has_scroll()') then
        vim.api.nvim_eval('coc#float#scroll(1)')
      end
    end

    local scroll_up_float_window = function()
      if vim.api.nvim_eval('coc#float#has_scroll()') then
        vim.api.nvim_eval('coc#float#scroll(0)')
      end
    end

    -- completion
    keymap("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"]],
      { expr = true })
    keymap("i", "<C-Space>", [[coc#refresh()]], { expr = true })
    -- diagnostic
    keymap("n", "g.", "<Plug>(coc-diagnostic-next)")
    keymap("n", "g,", "<Plug>(coc-diagnostic-prev)")
    -- code navigation
    keymap("n", "gd", "<Plug>(coc-definition)")
    keymap("n", "gD", "<Plug>(coc-implementation)")
    -- hover code action
    keymap("n", "K", show_docs)
    -- scroll float window
    keymap("n", "<C-n>", scroll_down_float_window)
    keymap("n", "<C-p>", scroll_up_float_window)
    -- symbol rename
    keymap("n", "gr", "<Plug>(coc-rename)")
    -- format
    keymap("n", "gf", "<Plug>(coc-format)")
    keymap("x", "gf", "<Plug>(coc-format-selected)")
    -- code action
    keymap("n", "ga", "<Plug>(coc-codeaction-cursor)")
    -- organize import
    keymap("n", "go", function()
      vim.fn.CocActionAsync('organizeImport')
    end)
  end,
}
