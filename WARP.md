# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

**sysinit** is a high-performance, modular Neovim configuration optimized for development workflow. It features:
- **~75ms startup time** with 30+ carefully selected plugins
- **Modular LSP system** with automatic tool management via Mason
- **Performance-first architecture** with lazy loading and caching
- **Modern Neovim 0.11+ APIs** throughout the codebase
- **No tests** - This is a personal configuration, not a distribution

## Essential Commands

### Bootstrap/Setup
```bash
# Install/update all plugins
nvim --headless "+Lazy! sync" +qa

# Profile startup performance
nvim --startuptime startup.log +qa

# Lint Lua files (requires selene)
selene lua/
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

# Diagnostics
:LspInfo               # Show LSP client status
:checkhealth           # Run all health checks

# Formatting and linting
:lua vim.lsp.buf.format()  # Format current buffer
```

## Architecture Overview

### Bootstrap Flow
```
init.lua
├── vim.loader.enable()     # Enable module caching (Neovim 0.11+)
├── require("config")       # Load core configuration
│   ├── Print ASCII art header
│   ├── setup_mason()       # Initialize Mason paths
│   ├── options.lua         # Neovim settings
│   ├── keymaps.lua         # Key mappings
│   └── autocmds.lua        # Auto commands
└── require("Lazy")         # Initialize plugin manager
    └── Import all plugins from lua/plugins/
```

### Error Handling Philosophy
- **Non-blocking startup**: Errors in module loading won't prevent Neovim from starting
- **Graceful degradation**: Failed modules show notifications but don't crash
- **Deferred error summary**: Full error report shown after 500ms delay
- **Module caching**: Failed module loads are retried on next require

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

## Code Quality

### Linting
- **selene** - Lua linter configured via `selene.toml`
- Configuration allows mixed tables, undefined variables (for vim globals)
- Runs on Lua files via command line: `selene lua/`

### No Testing Framework
This is a personal configuration without automated tests. Verification is done through:
- `:checkhealth` - Neovim health checks
- `:Lazy profile` - Plugin loading analysis
- Manual testing with `nvim --startuptime`

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
- `:LspShowFiletypeConfig [filetype]` - Show configuration for specific filetype
- `:LspClearCache` - Clear loader cache

## Performance Optimizations

This configuration is heavily optimized for startup performance and runtime efficiency:

### Startup Optimizations
- **`vim.loader.enable()`** - Byte-code caching for faster module loading
- **Disabled providers** - Perl, Ruby, Node, Python providers disabled in options.lua
- **Plugin lazy loading** - All plugins use `event`, `cmd`, or `keys` triggers
- **Large file detection** - Auto-optimization for files >1MB

### Runtime Optimizations
- **Plugin caching** - Enabled in lazy.nvim configuration
- **Treesitter optimization** - Disabled for large files automatically
- **Diagnostic debouncing** - Configured for optimal responsiveness

### Monitoring Performance
```bash
# Profile startup (target: <100ms)
:Lazy profile           # Profile plugin loading

# Check health
:checkhealth            # Run Neovim health checks
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
- **AI**: copilot.lua, copilot-lsp (NES), CopilotChat, sidekick (in ai.lua)
- **UI/UX**: onedarkpro (theme), lualine (statusline), noice (UI), trouble (diagnostics), vim-illuminate
- **Navigation**: telescope, harpoon, neovim-project
- **Git**: gitsigns, diffview (in git.lua and diffview.lua)
- **Editing**: better-escape, grug-far (find/replace), refactoring, suda (sudo), undo-tree
- **Utilities**: which-key, toggleterm, nvim-dap, nvim-dbee, snacks, nvim-bqf, showkeys, render-markdown

**Plugin file organization**: Each plugin spec is in a separate file under `lua/plugins/`, imported automatically by lazy.nvim.

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

## Performance Benchmarks

- **Current startup time**: ~75ms
- **Target startup time**: <100ms (good), <50ms (excellent)
- **Plugin count**: 30 carefully curated plugins
- **Memory usage**: Optimized with lazy loading
- **LSP languages**: Modular system (Lua, Python, Go, TypeScript configured by default)

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
:messages               # View error messages
```

### Debug Mode
Enable verbose logging for troubleshooting:
```lua
vim.lsp.set_log_level("debug")  -- Add to any config file temporarily
```

### Performance Debugging
If startup becomes slow:
1. Profile with `:Lazy profile` to identify bottlenecks
2. Check plugin lazy loading configuration
3. Verify large file detection is working (>2MB files)
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

### Performance Monitoring
Includes lazy.nvim profiling and Neovim's built-in health checks for diagnostics.
