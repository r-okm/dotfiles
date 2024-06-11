local ok, _ = pcall(require, "CopilotChat")
if ok then
  vim.schedule(function()
    vim.cmd.CopilotChatCommitStaged()
  end)
  vim.api.nvim_create_autocmd("QuitPre", {
    command = "CopilotChatClose",
  })

  vim.keymap.set("ca", "qq", "execute 'CopilotChatClose' <bar> wqa")
end
