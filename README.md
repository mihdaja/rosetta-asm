# rosetta-asm.nvim 🦀

A lightweight Neovim plugin to compile, run, and debug Linux **x86-64 GNU Assembler (GAS)** code on **macOS (Apple Silicon & Intel)** using Docker and Rosetta 2.

## ✨ Features

- **Automated Docker Lifecycle**:
  - Automatically installs Docker via Homebrew if missing (`brew install --cask docker` / `colima`).
  - Automatically starts Docker daemon silently in background if closed (`open -gj -a Docker`).
  - Automatically builds the embedded Ubuntu 24.04 + `gcc` + `lldb` image on first run.
- **Run in Linux ELF**: Compiles with `gcc -no-pie` and executes in an interactive terminal.
- **Rosetta 2 Debugging**: Launches target with `ROSETTA_DEBUGSERVER_PORT=1234` and connects `lldb` via `gdb-remote 1234`.
- **Zero Configuration**: Sensible defaults, auto-saving buffers before compile.

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/rosetta-asm.nvim",
  ft = { "asm", "s", "S", "gas" },
  opts = {
    image_name = "rosetta-asm-env",
    platform = "linux/amd64",
    compiler = "gcc",
    compiler_flags = { "-no-pie" },
    debug_port = 1234,
    auto_install_docker = true,
    auto_start_daemon = true,
    auto_build_image = true,
    keymaps = {
      run = "<leader>ca",
      debug = "<leader>cd",
    },
  },
}
```

## ⌨️ Default Keymaps & Commands

| Keymap | Command | Description |
| :--- | :--- | :--- |
| `<leader>ca` | `:AsmRun` | Compile & Run current `.s` file in Docker |
| `<leader>cd` | `:AsmDebug` | Compile with `-g`, start debugserver, attach LLDB |
| — | `:AsmBuildImage` | Force rebuild the Docker container image |
| — | `:AsmInstallDocker` | Install Docker / Colima via Homebrew |

## 📄 License

MIT
