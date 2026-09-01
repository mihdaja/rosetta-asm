local config = require("rosetta-asm.config")

local M = {}

--- Runs a command in an interactive terminal window
function M.open(cmd, cwd)
  local term_opts = config.options.terminal or {}

  -- Auto-save current buffer before running
  vim.cmd("silent! write")

  if _G.Snacks and Snacks.terminal then
    Snacks.terminal(cmd, {
      cwd = cwd,
      win = {
        position = term_opts.position or "bottom",
        height = term_opts.height or 0.4,
      },
    })
  else
    local height = math.floor(vim.o.lines * (term_opts.height or 0.4))
    vim.cmd(string.format("botright %dsplit | terminal %s", height, cmd))
    vim.cmd("startinsert")
  end
end

return M
