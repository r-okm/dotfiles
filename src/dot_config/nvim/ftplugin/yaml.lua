-- docker_compose_language_service を起動するため、ファイル名から docker-compose か否かを判定する
local function setup_docker_compose_lsp()
  local filename = vim.fn.expand("%:t")
  if string.match(filename, "docker%-compose") then
    vim.bo.filetype = "yaml.docker-compose"
  end
end

setup_docker_compose_lsp()
