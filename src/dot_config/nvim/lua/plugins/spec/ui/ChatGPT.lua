return {
  "jackMort/ChatGPT.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions", "ChatGPTRun", "ChatGPTCompleteCode" },
  config = function()
    local home = vim.fn.expand("$HOME")
    require("chatgpt").setup({
      api_key_cmd = "gpg --decrypt " .. home .. "/secrets/openai_api_key.txt.gpg",
    })
  end,
}
