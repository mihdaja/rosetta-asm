local M = {}

M.defaults = {
  image_name = "rosetta-asm-env",
  platform = "linux/amd64",
  compiler = "gcc",
  compiler_flags = { "-no-pie" },
  debug_port = 1234,
  auto_install_docker = true, -- Auto-installs Docker via brew if missing
  auto_start_daemon = true,   -- Auto-starts Docker background daemon if stopped
  auto_build_image = true,    -- Auto-builds container image if missing
  terminal = {
    position = "bottom",
    height = 0.4,
  },
  keymaps = {
    run = "<leader>ca",
    debug = "<leader>cd",
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
