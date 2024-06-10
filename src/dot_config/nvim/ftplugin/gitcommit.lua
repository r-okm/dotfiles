vim.schedule(function()
  require("CopilotChat")
  vim.cmd.CopilotChatCommitStaged()
end)
vim.api.nvim_create_autocmd("QuitPre", {
  command = "CopilotChatClose",
})

vim.keymap.set("ca", "qq", "execute 'CopilotChatClose' <bar> wqa")
