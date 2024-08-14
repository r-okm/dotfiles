-- docker_compose_language_service を起動するため、ファイル名から docker-compose か否かを判定する
local function setup_docker_compose_lsp()
  local filename = vim.fn.expand("%:t")

  local basenames = { "docker-compose", "compose" }
  local extensions = { ".yml", ".yaml" }

  -- filename が basenames + extensions にマッチする場合、filetype を yaml.docker-compose に変更する
  for _, basename in ipairs(basenames) do
    for _, extension in ipairs(extensions) do
      if filename == basename .. extension then
        vim.bo.filetype = "yaml.docker-compose"
        return
      end
    end
  end
end

setup_docker_compose_lsp()
