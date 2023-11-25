local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local notVscode = not vim.g.vscode
require("lazy").setup({
  spec = {
    { import = "plugins.spec.cmp",    cond = notVscode },
    { import = "plugins.spec.editor", cond = notVscode },
    { import = "plugins.spec.theme",  cond = notVscode },
    { import = "plugins.spec.ui",     cond = notVscode },
    { import = "plugins.spec.vscode" },
  },
  defaults = {
    version = "*",
  },
})

-- print plugins
local function printPlugins()
  vim.print(vim.tbl_keys(require("lazy.core.config").plugins))
end
vim.api.nvim_create_user_command("Plugins", printPlugins, {})
