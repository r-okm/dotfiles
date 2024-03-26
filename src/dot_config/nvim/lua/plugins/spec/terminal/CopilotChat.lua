return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "github/copilot.vim",
  },
  branch = "canary",
  build = function()
    vim.notify("Update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
  end,
  event = "VeryLazy",
  config = function()
    local chat = require("CopilotChat")
    local select = require("CopilotChat.select")
    local actions = require("CopilotChat.actions")
    local telescope = require("CopilotChat.integrations.telescope")

    chat.setup({
      prompts = {
        Review = "Review the provided code and suggest possible improvements. Answer in Japanese.",
        Refactor = "Improve the clarity and readability of the provided code through refactoring. Answer in Japanese.",
        Japanese = "Translate the provided English sentence into Japanese. Answer in Japanese.",
        English = "Translate the provided Japanese sentence into English. Answer in English.",
        -- default prompt
        Explain = {
          prompt = "/COPILOT_EXPLAIN Write an explanation for the code above as paragraphs of text. Answer in Japanese.",
        },
        Tests = {
          prompt = "/COPILOT_TESTS Write a set of detailed unit test functions for the code above. Answer in Japanese.",
        },
        Fix = {
          prompt = "/COPILOT_FIX There is a problem in this code. Rewrite the code to show it with the bug fixed. Answer in Japanese.",
        },
        Optimize = {
          prompt = "/COPILOT_REFACTOR Optimize the selected code to improve performance and readablilty. Answer in Japanese.",
        },
        Docs = {
          prompt = "/COPILOT_REFACTOR Write documentation for the selected code. The reply should be a codeblock containing the original code with the documentation added as comments. Use the most appropriate documentation style for the programming language used (e.g. JSDoc for JavaScript, docstrings for Python etc. Answer in Japanese.",
        },
        FixDiagnostic = {
          prompt = "Answer in Japanese. Please assist with the following diagnostic issue in file:",
          selection = select.diagnostics,
        },
        Commit = {
          prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit. Answer in Japanese.",
          selection = select.gitdiff,
        },
        CommitStaged = {
          prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit. Answer in Japanese.",
          selection = function(source)
            return select.gitdiff(source, true)
          end,
        },
      },
    })

    vim.keymap.set({ "n" }, "zu", function()
      local input = vim.fn.input("Quick Chat: ")
      if input ~= "" then
        chat.ask(input, { seletion = select.buffer })
      end
    end)
    vim.keymap.set({ "x" }, "zu", function()
      local input = vim.fn.input("Quick Chat: ")
      if input ~= "" then
        chat.ask(input, { seletion = select.visual })
      end
    end)
    vim.keymap.set({ "n" }, "zi", function()
      telescope.pick(actions.prompt_actions({ seletion = select.buffer }))
    end)
    vim.keymap.set({ "x" }, "zi", function()
      telescope.pick(actions.prompt_actions({ seletion = select.visual }))
    end)
  end,
}
