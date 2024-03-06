return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  build = function()
    vim.notify("Update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
  end,
  event = "VeryLazy",
  opts = {
    language = "Japanese",
    prompts = {
      Explain = "Explain the functionality of the provided code snippet.",
      Tests = "Generate corresponding unit tests for the provided code.",
      Review = "Review the provided code and suggest possible improvements.",
      Refactor = "Improve the clarity and readability of the provided code through refactoring.",
      Japanese = "Translate the provided English sentence into Japanese.",
      English = "Translate the provided Japanese sentence into English.",
    },
  },
  keys = {
    {
      "zu",
      mode = "n",
      function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          vim.cmd("CopilotChatBuffer " .. input)
        end
      end,
      desc = "CopilotChat - Quick chat",
    },
    {
      "zu",
      mode = "x",
      function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          vim.cmd("CopilotChatVisual " .. input)
        end
      end,
      desc = "CopilotChat - Quick chat",
    },
    {
      "zi",
      mode = "n",
      function()
        -- 現在開いているバッファ全体をヤンクする
        vim.cmd("%yank")
        require("CopilotChat.code_actions").show_prompt_actions()
      end,
      desc = "CopilotChat - Prompt actions",
    },
    {
      "zi",
      mode = "x",
      ":lua require('CopilotChat.code_actions').show_prompt_actions(true)<CR>",
      desc = "CopilotChat - Prompt actions",
    },
  },
}
