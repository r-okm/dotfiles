local const = require("utils.const")

return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost" },
  build = { ":TSUpdate" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "bash", "css", "diff", "dockerfile", "git_config",
        "git_rebase", "gitattributes", "gitcommit", "gitignore", "html", "javascript", "jq", "jsdoc", "json",
        "jsonc", "lua", "markdown", "markdown_inline", "terraform", "toml", "tsx",
        "typescript", "vim", "vimdoc",
      },
      highlight = {
        enable = true,
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > const.LARGE_FILE_LINE_COUNT
        end,
      },
    })
  end,
}
