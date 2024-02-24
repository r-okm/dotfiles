local keymap = require("utils.setKeymap").keymap

return {
  "neoclide/coc.nvim",
  cond = false,
  branch = "release",
  dependencies = {
    "fannheyward/telescope-coc.nvim",
  },
  event = { "BufReadPost", "BufNewFile", "CmdlineEnter" },
  config = function()
    vim.g.coc_global_extensions = {
      "coc-cfn-lint",
      "coc-css",
      "coc-docker",
      "coc-eslint",
      "coc-json",
      "coc-pairs",
      "coc-prettier",
      "coc-sh",
      "coc-snippets",
      "coc-sumneko-lua",
      "coc-toml",
      "coc-tsserver",
      "coc-yaml",
    }

    require("telescope").load_extension("coc")

    local show_docs = function()
      local cw = vim.fn.expand("<cword>")
      if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command("h " .. cw)
      elseif vim.api.nvim_eval("coc#rpc#ready()") then
        vim.fn.CocActionAsync("definitionHover")
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
    keymap("n", "gm", ":<C-u>Telescope coc workspace_diagnostics<CR>")
    -- code navigation
    keymap("n", "gd", ":<C-u>Telescope coc definitions<CR>")
    keymap("n", "gD", ":<C-u>Telescope coc implementations<CR>")
    keymap("n", "gt", ":<C-u>Telescope coc type_definitions<CR>")
    keymap("n", "grr", ":<C-u>Telescope coc references<CR>")
    -- hover code action
    keymap("n", "K", show_docs)
    -- scroll float window
    keymap("n", "<C-n>", scroll_down_float_window)
    keymap("n", "<C-p>", scroll_up_float_window)
    -- symbol rename
    keymap("n", "grn", "<Plug>(coc-rename)")
    -- format
    keymap("n", "gf", "<Plug>(coc-format)")
    keymap("x", "gf", "<Plug>(coc-format-selected)")
    -- code action
    keymap("n", "ga", "<Plug>(coc-codeaction-cursor)")
    keymap("n", "gA", ":<C-u>Telescope coc code_actions<CR>")
    -- organize import
    keymap("n", "go", function()
      vim.fn.CocActionAsync("organizeImport")
    end)
  end,
}
