# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

**sysinit** is a high-performance, modular Neovim configuration optimized for development workflow. It features:
- **~75ms startup time** with 30+ carefully selected plugins
- **Modular LSP system** with automatic tool management via Mason
- **Performance-first architecture** with lazy loading and caching
- **Built-in health monitoring** and startup profiling
- **Modern Neovim 0.11+ APIs** throughout the codebase

## Essential Commands

### Bootstrap/Setup
```bash
# Install/update all plugins
nvim --headless "+Lazy! sync" +qa

# Run configuration health check
nvim --headless "+ConfigHealth" +qa

# Profile startup performance
nvim --startuptime startup.log +qa
```

### Development Workflow
```bash
# Plugin management
:Lazy                    # Open plugin manager
:Lazy sync              # Update all plugins
:Lazy profile           # Profile plugin loading times

# LSP management
:LspShowConfigs         # Show all loaded language configurations
:LspInstallMissing      # Install missing LSP tools via Mason
:LspShowTools           # Display available tools by type
:Mason                  # Open Mason tool manager

# Health and diagnostics
:ConfigHealth           # Run configuration health check
:ProfileStartup         # Profile startup performance  
:LspInfo               # Show LSP client status
:checkhealth           # Run all health checks

# Formatting and linting
:lua vim.lsp.buf.format()  # Format current buffer
```

## Architecture Overview

### Bootstrap Flow
```
init.lua
├── vim.loader.enable()     # Enable module caching
├── require("config")       # Load core configuration
└── require("Lazy")         # Initialize plugin manager
```

### Core Structure
```
├── init.lua                    # Main entry point with error handling
├── lua/
│   ├── config/                 # Core configuration modules
│   │   ├── init.lua           # Config loader with ASCII art header
│   │   ├── options.lua        # Neovim settings (performance optimized)
│   │   ├── keymaps.lua        # Key mappings (helper function approach)
│   │   ├── autocmds.lua       # Auto commands (grouped by purpose)
│   │   └── utils.lua          # Path management and Mason setup
│   ├── lsp/                   # Modular LSP system
│   │   ├── init.lua           # LSP entry point
│   │   ├── loader.lua         # Modern LSP loader with caching
│   │   ├── config.lua         # Global LSP configuration
│   │   ├── capabilities.lua   # Enhanced LSP capabilities
│   │   ├── diagnostics.lua    # Diagnostic configuration
│   │   ├── keymaps.lua        # LSP keybindings
│   │   ├── notifications.lua  # Notification control system
│   │   ├── commands.lua       # LSP management commands
│   │   ├── utils.lua          # LSP utility functions
│   │   ├── configs/           # Language-specific configurations
│   │   └── README.md          # Comprehensive LSP documentation
│   ├── Lazy.lua               # Plugin manager initialization
│   └── plugins/               # Plugin specifications (lazy-loaded)
├── selene.toml                # Lua linting configuration
├── .gitignore                 # Git ignore patterns
└── lazy-lock.json            # Plugin version lockfile (gitignored)
```

## LSP Architecture

The LSP system is the most sophisticated component, featuring automatic tool management and modular configuration:

### Key Components
- **`lua/lsp/loader.lua`** - Core loading system with caching and performance optimization
- **`lua/lsp/config.lua`** - Global LSP handlers, diagnostics, and capabilities
- **Language configs** - Per-language configurations in the configs/ directory
- **Mason integration** - Automatic tool installation and management

### Language Configuration Pattern
Each language follows this structure in `lua/lsp/configs/language.lua`:
```lua
return {
  lsp = {
    server_name = {
      settings = { --[[ server settings ]] },
      on_attach = function(client, bufnr) end,
    },
  },
  format = { filetype = { "formatter1", "formatter2" } },
  lint = { filetype = { "linter1", "linter2" } },
  lint_config = {
    -- Custom linter configurations like selene with config file
    linter_name = {
      cmd = "command",
      args = { "--config", "path/to/config" },
      stdin = false,
    },
  },
}
```

### LSP Management Commands
- `:LspShowConfigs` - Display all loaded language configurations
- `:LspShowTools` - Show available tools by type (lsp, format, lint)
- `:LspInstallMissing [type]` - Install missing tools via Mason
- `:LspNewConfig <name>` - Create new language configuration template
- `:LspReloadConfigs` - Reload all configurations
- `:LspShowCustomLinters` - View custom linter configurations with full details

### Notification Control
By default, all non-error LSP notifications are disabled for performance. Control with:
- `:LspToggleAllNotifications` - Toggle all non-error notifications
- `:LspToggleAttachNotifications` - Toggle LSP attach/detach messages
- `:LspToggleServerNotifications` - Toggle server management messages

## Performance Optimizations

This configuration is heavily optimized for startup performance and runtime efficiency:

### Startup Optimizations
- **`vim.loader.enable()`** - Byte-code caching for faster module loading
- **Disabled providers** - Perl, Ruby, Node, Python providers disabled in options.lua
- **Plugin lazy loading** - All plugins use `event`, `cmd`, or `keys` triggers
- **Large file detection** - Auto-optimization for files >1MB

### Runtime Optimizations
- **LSP notification silencing** - Reduces noise and improves performance
- **Plugin caching** - Enabled in lazy.nvim configuration
- **Treesitter optimization** - Disabled for large files automatically
- **Diagnostic debouncing** - Configured for optimal responsiveness

### Monitoring Performance
```bash
# Profile startup (target: <50ms)
:ProfileStartup

# Plugin load profiling
:Lazy profile

# Monitor health
:ConfigHealth
```

## Plugin Management

### Plugin Manager: lazy.nvim
- **Location**: All plugin specs in `lua/plugins/`
- **Loading strategy**: Event-driven lazy loading
- **Version control**: `lazy-lock.json` tracks exact versions
- **Performance**: Disabled unused runtime plugins in `performance.rtp.disabled_plugins`

### Plugin Categories
- **Core**: lazy.nvim, blink.cmp (completion), nvim-treesitter
- **LSP**: nvim-lspconfig, mason.nvim, conform.nvim, nvim-lint
- **AI**: copilot.lua, copilot-lsp (NES), CopilotChat, sidekick
- **UI/UX**: onedarkpro (theme), lualine (statusline), noice (UI), trouble (diagnostics)
- **Navigation**: telescope, harpoon, neovim-project
- **Git**: gitsigns, diffview, worktree
- **Utilities**: which-key, toggleterm, nvim-dap, nvim-dbee, snacks

### Adding New Plugins
Create new file in `lua/plugins/` following this pattern:
```lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- or cmd, keys, ft for lazy loading
  opts = { },          -- or config = function() end
  dependencies = { },  -- optional dependencies
}
```

## Testing and Validation

### Health Checks
The configuration includes comprehensive health monitoring:
- **Configuration loading validation** - Ensures all modules load correctly
- **Plugin status verification** - Checks essential plugins are functional  
- **External tool availability** - Verifies rg, fd, git are available
- **LSP configuration counting** - Reports number of language configs
- **Startup performance tracking** - Monitors and reports timing

### Performance Benchmarks
- **Current startup time**: ~75ms
- **Target startup time**: <100ms (good), <50ms (excellent)
- **Plugin count**: 30+ (carefully curated)
- **Memory usage**: Optimized with lazy loading
- **LSP languages**: Modular system (Lua configured by default)

## Troubleshooting

### Common Issues
```bash
# Slow startup
:ProfileStartup          # Check what's taking time
:Lazy profile           # Profile plugin loading

# LSP not working
:LspInfo                # Check LSP client status
:LspShowConfigs         # Verify language configurations
:LspInstallMissing      # Install missing tools
:Mason                  # Check Mason tool status

# Plugin issues
:Lazy                   # Open plugin manager
:Lazy sync              # Update plugins
:checkhealth            # Run comprehensive health check

# Configuration errors  
:ConfigHealth           # Run configuration health check
:messages               # View error messages
```

### Debug Mode
Enable verbose logging for troubleshooting:
```lua
vim.lsp.set_log_level("debug")  -- Add to any config file temporarily
```

### Performance Debugging
If startup becomes slow:
1. Run `:ProfileStartup` to identify bottlenecks
2. Check plugin lazy loading configuration
3. Verify large file detection is working
4. Review disabled providers in options.lua

## Key Features Unique to This Config

### ASCII Art Startup Header
The configuration displays a custom ASCII art header defined in `lua/config/init.lua`.

### Helper Function Keymaps
Keymaps use a helper function approach in `lua/config/keymaps.lua` for maintainability:
```lua
map("n", "<leader>x", ":command", "Description")
```

### Custom Linter Configuration
Supports complex linter setups like selene with custom config files via `lint_config` sections.

### Window Navigation Integration
Includes zellij-nav plugin for seamless terminal multiplexer integration.

### Dynamic Which-Key Group Registration
Plugins can dynamically register their which-key groups using the `config.which_key_groups` registry:

```lua
return {
  "plugin/name",
  init = function()
    -- Register which-key group early (before which-key loads)
    require("config.which_key_groups").register("plugin-name", {
      {
        mode = { "n", "v" },
        { "<leader>x", group = "Plugin Name" },
      },
    })
  end,
  -- ... rest of plugin config
}
```

**Critical**: Use the `init` function (not `config`) to ensure groups are registered before which-key is loaded. This solves timing issues where groups defined in `config` functions aren't available when which-key displays.

### Performance Monitoring Built-in
Includes startup profiling, health checks, and performance monitoring as first-class features.
