local config = require("rosetta-asm.config")
local docker = require("rosetta-asm.docker")
local terminal = require("rosetta-asm.terminal")

local M = {}

--- Retrieves file, directory, and target binary details from the current buffer
function M.get_buffer_info()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    vim.notify("[rosetta-asm] Current buffer has no file name. Please save it first.", vim.log.levels.WARN)
    return nil
  end

  local dir = vim.fn.fnamemodify(file_path, ":p:h")
  local src = vim.fn.fnamemodify(file_path, ":t")
  local out = vim.fn.fnamemodify(file_path, ":t:r")

  return {
    dir = dir,
    src = src,
    out = out,
    full_path = file_path,
  }
end

--- Compiles and runs the current assembly file in Docker
function M.run()
  local info = M.get_buffer_info()
  if not info then
    return
  end

  local opts = config.options
  local compiler = opts.compiler or "gcc"
  local flags = table.concat(opts.compiler_flags or { "-no-pie" }, " ")

  local inner_cmd = string.format(
    "%s %s -o %s %s && echo '=== Running ./%s ===' && ./%s ; echo '' ; read -p 'Press Enter to close...' _",
    compiler,
    flags,
    vim.fn.shellescape(info.out),
    vim.fn.shellescape(info.src),
    info.out,
    vim.fn.shellescape(info.out)
  )

  local cmd = docker.wrap_docker_run(inner_cmd, info.dir)
  terminal.open(cmd, info.dir)
end

return M
