return function()
  if vim.g.vscode then
    return
  end

  require('nvim-treesitter.configs').setup {
    ensure_installed = {
      'bash',
      'css',
      'diff',
      'dockerfile',
      'gitcommit',
      'gitignore',
      'html',
      'java',
      'javascript',
      'json',
      'jsonc',
      'lua',
      'markdown',
      'scss',
      'sql',
      'toml',
      'tsx',
      'typescript',
      'vim',
      'vue',
      'yaml',
    },
  }
end
