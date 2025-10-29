# Modern LSP Configuration System

This is a comprehensive, performant LSP loader system for Neovim 0.11+ that automatically loads and configures LSP servers, formatters, and linters from modular configuration files.

## Architecture

### Core Components

- **`loader.lua`** - Main loading system with caching and lazy loading
- **`config.lua`** - Global LSP configuration (handlers, diagnostics)
- **`capabilities.lua`** - Enhanced LSP capabilities
- **`keymaps.lua`** - LSP keymaps and server management commands
- **`diagnostics.lua`** - Diagnostic signs and configuration
- **`commands.lua`** - Management commands for the loader
- **`configs/`** - Language-specific configuration files

### Configuration Files Structure

Each language config follows this pattern:

```lua
-- lua/lsp/configs/language.lua
return {
  -- LSP servers for the language
  lsp = {
    server_name = {
      settings = { -- server specific settings },
      on_attach = function(client, bufnr) end, -- optional
      capabilities = {}, -- optional overrides
    },
  },

  -- Formatters (used by conform.nvim)
  format = {
    filetype = { "formatter1", "formatter2" },
  },

  -- Linters (used by nvim-lint)
  lint = {
    filetype = { "linter1", "linter2" },
  },

  -- Custom linter configurations (optional)
  lint_config = {
    linter_name = {
      cmd = "command_name",
      args = { "--arg1", "--arg2" },
      stdin = false,
      stream = "stdout",
      ignore_exitcode = false,
      parser = require("lint.parser").from_errorformat("%f:%l:%c: %m"),
    },
  },

  -- DAP configurations (optional)
  dap = {
    adapter_name = { -- DAP configuration },
  },
}
```

## Features

### ✨ **Automatic Tool Management**

- Reads all config files from `lua/lsp/configs/`
- Extracts LSP servers, formatters, linters, and debuggers
- Automatically installs missing tools via Mason
- Caches results for performance

### ⚡ **Performance Optimized**

- Lazy loading of modules
- Configuration caching
- Minimal startup impact
- Smart tool detection and deduplication

### 🛠️ **Modern API Support**

- Uses `vim.lsp.config` API (Neovim 0.11+)
- Modern diagnostic configuration
- Enhanced LSP capabilities
- Proper error handling

### 🔧 **Management Commands**

- `:LspShowConfigs` - Show all loaded configurations
- `:LspShowTools` - Show available tools by type
- `:LspShowFiletypeConfig [filetype]` - Show config for specific filetype
- `:LspReloadConfigs` - Reload all configurations
- `:LspInstallMissing [tool_types]` - Install missing tools
- `:LspNewConfig <name>` - Create new config template
- `:LspShowCustomLinters` - Show detailed custom linter configurations
- `:LspClearCache` - Clear loader cache

## Usage

### Basic Setup

The system auto-loads when you require the LSP module. No manual configuration needed:

```lua
require("lsp") -- Automatically loads everything
```

### Plugin Manager Integration

LazyNvim example:

```lua
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "stevearc/conform.nvim",
    "mfussenegger/nvim-lint",
    "mason-org/mason.nvim",
  },
  config = function()
    -- The LSP module handles everything including dependency configuration
    require("lsp")
  end,
}
```

### Adding a New Language

1. **Create config file:**

   ```bash
   :LspNewConfig rust
   ```

2. **Edit the generated template:**

   ```lua
   -- lua/lsp/configs/rust.lua
   return {
     lsp = {
       rust_analyzer = {
         settings = {
           ["rust-analyzer"] = {
             cargo = { allFeatures = true },
             checkOnSave = { command = "clippy" },
           },
         },
       },
     },
     format = {
       rust = { "rustfmt" },
     },
     lint = {
       rust = { "clippy" },
     },
   }
   ```

3. **Reload configs:**
   ```bash
   :LspReloadConfigs
   ```

### Configuring Custom Linters

For linters that need special arguments or configurations (like selene needing a config file path), use the `lint_config` section:

```lua
-- lua/lsp/configs/lua.lua
return {
  -- Standard linter setup
  lint = {
    lua = { "selene" },
  },
  
  -- Custom linter configuration
  lint_config = {
    selene = {
      cmd = "selene",
      stdin = false,
      args = { "--config", vim.fn.stdpath("config") .. "/selene.toml" },
      stream = "stdout",
      ignore_exitcode = false,
      parser = require("lint.parser").from_errorformat(
        "%f:%l:%c: %t%*[^:]: %m",
        {
          source = "selene",
          severity = vim.diagnostic.severity.WARN,
        }
      ),
    },
  },
}
```

**Custom linter configuration options:**
- `cmd` - The command to run
- `args` - Array of arguments to pass to the command
- `stdin` - Whether to use stdin for input (default: true)
- `stream` - Which stream to read from ("stdout", "stderr", "both")
- `ignore_exitcode` - Whether to ignore non-zero exit codes
- `parser` - Function to parse the linter output into diagnostics

### Customizing LSP Keymaps

You can customize or disable LSP keymaps by configuring them in your LSP setup:

```lua
local keymaps = require("lsp.keymaps")

-- Disable specific keymaps
keymaps.configure_keymaps({
  ["gt"] = false,  -- Disable "go to type definition"
  ["<leader>rn"] = false,  -- Disable rename
})

-- Override or add new keymaps
keymaps.configure_keymaps({
  -- Override existing keymap
  ["gr"] = { "n", "gr", vim.lsp.buf.references, "Find references" },
  
  -- Add new keymap
  ["<leader>lr"] = { "n", "<leader>lr", vim.lsp.buf.references, "LSP references" },
})
```

**Default LSP keymaps:**
- `gd` - Go to definition
- `gD` - Go to declaration  
- `gi` - Go to implementation
- `gr` - Show references
- `gt` - Go to type definition
- `K` - Show hover documentation
- `<C-k>` - Show signature help
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>f` - Format document/range
- `[d`/`]d` - Go to previous/next diagnostic
- `<leader>e` - Show line diagnostics
- `<leader>wa`/`<leader>wr`/`<leader>wl` - Workspace management
- `<leader>ds`/`<leader>ws` - Document/workspace symbols
- `<leader>ih` - Toggle inlay hints (if supported)

### Checking Configuration

```bash
# Show all loaded configs
:LspShowConfigs

# Show config for current filetype
:LspShowFiletypeConfig

# Show config for specific filetype
:LspShowFiletypeConfig python

# Show all available tools
:LspShowTools

# Show custom linter configurations
:LspShowCustomLinters
```

### Installing Tools

```bash
# Install all missing tools
:LspInstallMissing

# Install only LSP servers
:LspInstallMissing lsp

# Install formatters and linters
:LspInstallMissing format lint
```

## Current Language Configurations

The system includes pre-configured support for:

- **Lua** - lua_ls, stylua, selene
- **Python** - pyright, ruff_format, isort, ruff, mypy
- **Go** - gopls, gofumpt, goimports-reviser, golangci-lint
- **TypeScript/JavaScript** - ts_ls, eslint, prettier

## Integration

### With conform.nvim (Formatting)

The loader automatically configures conform.nvim with `formatters_by_ft` from all config files.

### With nvim-lint (Linting)

The loader automatically configures nvim-lint with `linters_by_ft` from all config files.

### With Mason

Tools are automatically installed via Mason based on configurations.

## Advanced Configuration

### Custom Loader Options

```lua
local loader = require("lsp.loader")
loader.setup({
  -- Mason configuration
  mason = { ui = { border = "rounded" } },

  -- Tool installation
  ensure_installed = true,
  tool_types = { "lsp", "format", "lint" },

  -- Feature toggles
  formatting = true,
  linting = true,

  -- Custom capabilities
  capabilities = require("custom.capabilities"),
})
```

### Programmatic Access

```lua
local loader = require("lsp.loader")

-- Get all tools
local tools = loader.get_tools()
local lsp_servers = loader.get_tools("lsp")

-- Get config data
local formatters = loader.get_config_data("format")
local python_linters = loader.get_config_data("lint", "python")

-- Read configs
local configs = loader.read_configs()

-- Setup specific components
loader.setup_lsp_servers(capabilities)
loader.setup_formatting()
loader.setup_linting()
```

## Performance Notes

- Configs are cached after first load
- Tools are cached and deduplicated
- Modules are lazy-loaded on demand
- Minimal impact on startup time
- Cache can be cleared with `:LspClearCache`

## Troubleshooting

### Config not loading?

```bash
:LspShowConfigs  # Check if config is loaded
:LspClearCache   # Clear cache
:LspReloadConfigs # Force reload
```

### Tools not installing?

```bash
:LspShowTools      # Check detected tools
:LspInstallMissing # Try installing again
:Mason             # Check Mason UI
```

### LSP not starting?

```bash
:LspInfo                    # Check LSP status
:LspShowFiletypeConfig     # Check config for current file
:checkhealth lsp           # Run health check
```
