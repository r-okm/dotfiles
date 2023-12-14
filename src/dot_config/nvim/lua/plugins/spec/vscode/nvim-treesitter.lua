local const = require("utils.const")

return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost" },
  build = { ":TSUpdate" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "html",
        "java",
        "javascript",
        "jq",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "scss",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
      },
      highlight = {
        enable = not vim.g.vscode,
        disable = function(_, bufnr)
          return vim.api.nvim_buf_line_count(bufnr) > const.LARGE_FILE_LINE_COUNT
        end,
      },
    })
    vim.cmd([[
      set nofoldenable
      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
    ]])
  end,
}
