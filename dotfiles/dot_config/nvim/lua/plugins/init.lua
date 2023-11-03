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

require("lazy").setup("plugins.spec", {
  defaults = {
    version = "*",
  },
})

-- print plugins
local function printPlugins()
  vim.print(vim.tbl_keys(require("lazy.core.config").plugins))
end
vim.api.nvim_create_user_command("Plugins", printPlugins, {})
