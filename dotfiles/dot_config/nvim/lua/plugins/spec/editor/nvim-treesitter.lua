return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost" },
  build = { ":TSUpdate" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "bash", "c", "c_sharp", "cpp", "css", "diff", "dockerfile", "git_config",
        "git_rebase", "gitattributes", "gitcommit", "gitignore", "html", "java", "javascript", "jq", "jsdoc", "json",
        "jsonc", "lua", "markdown", "markdown_inline", "sql", "terraform", "toml", "tsx",
        "typescript", "vim", "vimdoc",
      },
      highlight = {
        enable = true,
      },
    })
  end,
}
