local keymap = require("utils.setKeymap").keymap

return {
  "neoclide/coc.nvim",
  branch = "release",
  event = { "BufReadPost", "BufNewFile", "CmdlineEnter" },
  config = function()
    local show_docs = function()
      local cw = vim.fn.expand("<cword>")
      if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command("h " .. cw)
      elseif vim.api.nvim_eval("coc#rpc#ready()") then
        vim.fn.CocActionAsync("doHover")
      else
        vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
      end
    end

    local scroll_down_float_window = function()
      if vim.api.nvim_eval("coc#float#has_scroll()") then
        vim.api.nvim_eval("coc#float#scroll(1)")
      end
    end

    local scroll_up_float_window = function()
      if vim.api.nvim_eval("coc#float#has_scroll()") then
        vim.api.nvim_eval("coc#float#scroll(0)")
      end
    end

    -- textobj
    keymap("xo", "if", "<Plug>(coc-funcobj-i)")
    keymap("xo", "af", "<Plug>(coc-funcobj-a)")
    keymap("xo", "ic", "<Plug>(coc-classobj-i)")
    keymap("xo", "ac", "<Plug>(coc-classobj-a)")
    -- completion
    keymap(
      "i",
      "<CR>",
      [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"]],
      { expr = true }
    )
    keymap("i", "<C-Space>", [[coc#start()]], { expr = true })
    keymap("i", "<C-u>", [[coc#pum#stop()]], { expr = true })
    -- diagnostic
    keymap("n", "g.", "<Plug>(coc-diagnostic-next)")
    keymap("n", "g,", "<Plug>(coc-diagnostic-prev)")
    keymap("n", "gm", ":<C-u>CocList diagnostics<CR>")
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
      vim.fn.CocActionAsync("organizeImport")
    end)
  end,
}
