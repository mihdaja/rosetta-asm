local config = require("rosetta-asm.config")
local docker = require("rosetta-asm.docker")
local runner = require("rosetta-asm.runner")
local terminal = require("rosetta-asm.terminal")

local M = {}

--- Compiles with debug symbols and launches LLDB connected to Rosetta debugserver
function M.debug()
  local info = runner.get_buffer_info()
  if not info then
    return
  end

  local opts = config.options
  local compiler = opts.compiler or "gcc"
  local flags = table.concat(opts.compiler_flags or { "-no-pie" }, " ")
  local port = opts.debug_port or 1234

  local inner_cmd = string.format(
    "%s %s -g -o %s %s && (ROSETTA_DEBUGSERVER_PORT=%d ./%s &) && sleep 0.3 && lldb ./%s -o 'gdb-remote %d'",
    compiler,
    flags,
    vim.fn.shellescape(info.out),
    vim.fn.shellescape(info.src),
    port,
    vim.fn.shellescape(info.out),
    vim.fn.shellescape(info.out),
    port
  )

  local cmd = docker.wrap_docker_run(inner_cmd, info.dir)
  terminal.open(cmd, info.dir)
end

return M
