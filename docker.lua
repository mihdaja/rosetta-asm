local config = require("rosetta-asm.config")

local M = {}

M.DEFAULT_DOCKERFILE = [[
FROM --platform=linux/amd64 ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        gdb \
        lldb \
        binutils \
        libc6-dev \
        make \
        nasm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
]]

--- Generates shell prelude that ensures:
--- 1. Docker is installed (attempts brew install if missing)
--- 2. Docker daemon is running (silently starts it if stopped)
--- 3. Container image is built
function M.get_ensure_docker_cmd()
  local opts = config.options
  local image = opts.image_name
  local platform = opts.platform

  local steps = {}

  -- 1. Ensure docker CLI is installed
  if opts.auto_install_docker then
    local install_cli = "if ! command -v docker >/dev/null 2>&1; then "
      .. "echo '=== Docker not found. Installing via Homebrew... ===' && "
      .. "(brew install --cask docker 2>/dev/null || brew install colima docker) ; "
      .. "fi"
    table.insert(steps, install_cli)
  end

  -- 2. Ensure Docker background daemon is running
  if opts.auto_start_daemon then
    local start_daemon = "if ! docker info >/dev/null 2>&1; then "
      .. "echo '=== Starting Docker background service... ===' && "
      .. "(open -gj -a Docker 2>/dev/null || (command -v colima >/dev/null && colima start --rosetta 2>/dev/null)) && "
      .. "until docker info >/dev/null 2>&1; do sleep 1; done && "
      .. "echo '=== Docker service ready ===' ; "
      .. "fi"
    table.insert(steps, start_daemon)
  end

  -- 3. Ensure Docker image is built
  if opts.auto_build_image then
    -- Construct embedded dockerfile build command
    local escaped_df = vim.fn.shellescape(M.DEFAULT_DOCKERFILE)
    local build_img = string.format(
      "if ! docker image inspect %s >/dev/null 2>&1; then "
        .. "echo '=== Building %s container image... ===' && "
        .. "printf %%s %s | docker build --platform %s -t %s - && "
        .. "echo '=== Image built successfully ===' ; "
        .. "fi",
      vim.fn.shellescape(image),
      image,
      escaped_df,
      vim.fn.shellescape(platform),
      vim.fn.shellescape(image)
    )
    table.insert(steps, build_img)
  end

  return table.concat(steps, " && ")
end

--- Builds a full docker run command for the specified inner command
function M.wrap_docker_run(inner_cmd, host_dir)
  local opts = config.options
  local prelude = M.get_ensure_docker_cmd()

  local docker_run = string.format(
    "docker run --rm -it --platform %s -v %s:/work -w /work %s bash -c %s",
    vim.fn.shellescape(opts.platform),
    vim.fn.shellescape(host_dir),
    vim.fn.shellescape(opts.image_name),
    vim.fn.shellescape(inner_cmd)
  )

  if prelude ~= "" then
    return prelude .. " && " .. docker_run
  end
  return docker_run
end

return M
