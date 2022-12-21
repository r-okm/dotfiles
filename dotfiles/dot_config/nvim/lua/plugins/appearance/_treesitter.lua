return function()
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
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 500,
    },
  }
end
