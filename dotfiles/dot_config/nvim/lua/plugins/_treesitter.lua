return function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = {
      'bash',
      'css',
      'diff',
      'gitcommit',
      'gitignore',
      'html',
      'java',
      'json',
      'lua',
      'markdown',
      'scss',
      'sql',
      'tsx',
      'typescript',
      'vim',
      'vue',
      'yaml',
    }
  }
end
