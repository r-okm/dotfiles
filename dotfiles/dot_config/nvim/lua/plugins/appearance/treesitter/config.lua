return function()
  require("nvim-treesitter.configs").setup {
    ensure_installed = {
      "bash",
      "css",
      "diff",
      "dockerfile",
      "gitcommit",
      "gitignore",
      "html",
      "java",
      "javascript",
      "json",
      "jsonc",
      "lua",
      "markdown",
      "scss",
      "sql",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vue",
      "yaml",
    },
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
  }
end
