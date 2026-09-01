local config = require("rosetta-asm.config")
local runner = require("rosetta-asm.runner")
local debugger = require("rosetta-asm.debugger")
local docker = require("rosetta-asm.docker")
local terminal = require("rosetta-asm.terminal")

local M = {}

M.run = runner.run
M.debug = debugger.debug

--- Force rebuilds the Docker container image
function M.build_image()
  local opts = config.options
  local escaped_df = vim.fn.shellescape(docker.DEFAULT_DOCKERFILE)
  local cmd = string.format(
    "echo '=== Force rebuilding %s image... ===' && printf %%s %s | docker build --no-cache --platform %s -t %s - && echo '=== Build finished ==='",
    opts.image_name,
    escaped_df,
    vim.fn.shellescape(opts.platform),
    vim.fn.shellescape(opts.image_name)
  )
  terminal.open(cmd, vim.fn.getcwd())
end

--- Installs Docker via Homebrew
function M.install_docker()
  local cmd = "echo '=== Installing Docker via Homebrew... ===' && (brew install --cask docker || brew install colima docker)"
  terminal.open(cmd, vim.fn.getcwd())
end

--- Plugin setup function
function M.setup(opts)
  config.setup(opts)

  -- Register User Commands
  vim.api.nvim_create_user_command("AsmRun", function()
    M.run()
  end, { desc = "Compile and Run GAS assembly in Docker" })

  vim.api.nvim_create_user_command("AsmDebug", function()
    M.debug()
  end, { desc = "Compile and Debug GAS assembly with LLDB & Rosetta" })

  vim.api.nvim_create_user_command("AsmBuildImage", function()
    M.build_image()
  end, { desc = "Force rebuild rosetta-asm Docker image" })

  vim.api.nvim_create_user_command("AsmInstallDocker", function()
    M.install_docker()
  end, { desc = "Install Docker runtime via Homebrew" })

  -- Register Keymaps if configured
  local keymaps = config.options.keymaps
  if keymaps then
    if keymaps.run then
      vim.keymap.set("n", keymaps.run, function()
        M.run()
      end, { desc = "Assemble & Run in Docker (gcc)" })
    end

    if keymaps.debug then
      vim.keymap.set("n", keymaps.debug, function()
        M.debug()
      end, { desc = "Assemble & Debug in Docker (lldb)" })
    end
  end
end

return M
