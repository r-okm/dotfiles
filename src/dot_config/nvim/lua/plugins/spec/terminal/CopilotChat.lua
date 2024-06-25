return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "github/copilot.vim",
  },
  branch = "canary",
  cond = os.getenv("GITHUB_COPILOT_ENABLED") == "1",
  config = function()
    local chat = require("CopilotChat")
    local select = require("CopilotChat.select")
    local actions = require("CopilotChat.actions")
    local default_config = require("CopilotChat.config")
    local telescope = require("CopilotChat.integrations.telescope")

    local additional_prompt = [[ Your answer must be JAPANESE.
また、回答は以下の規約に従う。
* 日本語で回答する
* 敬体を使用せず、常体を使用する
* 英語の回答は日本語に翻訳して回答する
* 日本語文中の半角英数字は前後に半角スペースを一つ入れる
]]
    local prompts = {
      Japanese = "Translate the provided English sentence into Japanese.",
      English = "Translate the provided Japanese sentence into English.",
    }
    for prompt_title, config in pairs(default_config.prompts) do
      config.prompt = config.prompt .. additional_prompt
      prompts[prompt_title] = config
    end

    prompts.CommitStaged.prompt = prompts.CommitStaged.prompt
      .. "* コードの変更内容は箇条書きで記述する"

    chat.setup({
      prompts = prompts,
      mappings = {
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          -- Default <Tab> setting conflicts with cmp and coc-nvim
          insert = "<S-Tab>",
        },
      },
    })

    vim.keymap.set({ "n" }, "zu", function()
      vim.cmd("CopilotChatOpen")
    end)
    vim.keymap.set({ "x" }, "zu", function()
      vim.cmd("CopilotChat")
    end)
    vim.keymap.set({ "n" }, "zi", function()
      telescope.pick(actions.prompt_actions({ selection = select.buffer }))
    end)
    vim.keymap.set({ "x" }, "zi", function()
      telescope.pick(actions.prompt_actions({ selection = select.visual }))
    end)
  end,
}
