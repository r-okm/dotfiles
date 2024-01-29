return {
  "jellydn/CopilotChat.nvim",
  opts = {
    mode = "split", -- newbuffer or split  , default: newbuffer
    prompts = {
      Explain = "Please explain how the following code works. Answer in Japansese.",
      Tests = "Please explain how the selected code works, then generate unit tests for it. Answer in Japansese.",
      Review = "Please review the following code and provide suggestions for improvement. Answer in Japansese.",
      Refactor = "Please refactor the following code to improve its clarity and readability. Answer in Japansese.",
    },
  },
  build = function()
    vim.defer_fn(function()
      vim.cmd("UpdateRemotePlugins")
      vim.notify("CopilotChat - Updated remote plugins. Please restart Neovim.")
    end, 3000)
  end,
  event = "VeryLazy",
  keys = {
    { "<Space>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
    { "<Space>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
    { "<Space>ccr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
    { "<Space>ccR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor tests" },
  },
}
